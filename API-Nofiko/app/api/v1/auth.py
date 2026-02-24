from fastapi import APIRouter, Response, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from jose import JWTError
from authlib.integrations.starlette_client import OAuth

from app.core.security import create_access_token, create_refresh_token, decode_token
from app.db.database import get_db
from app.crud.user import userCrud
from app.core.config import settings
from app.schemas.user import UserCreateGoogle
from app.crud.refresh_token import refreshTokenCrud

router = APIRouter()


#pour L'SSO avec Google
oauth = OAuth()
oauth.register(
    name='google',
    client_id=settings.google_client_id,
    client_secret=settings.google_client_secret,
    server_metadata_url='https://accounts.google.com/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid email profile'}
)


@router.post("/login")
def login_user(
    request: Request,
    response: Response,
    db: Session = Depends(get_db),
    form_data: OAuth2PasswordRequestForm = Depends(),
):
    """
    Authentifie un utilisateur.
    """
    user = userCrud.authenticate(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Identifiants invalides"
        )

    send_all_token(user.id, response, db,request)

    return {"message": "Connexion réussie"}

@router.get("/login/google")
async def login_google(request: Request):
    """Redirige l'utilisateur vers la page de connexion Google."""
    redirect_uri = request.url_for('auth_google') 
    return await oauth.google.authorize_redirect(request, redirect_uri)

@router.get("/google")
async def auth_google(request: Request, response: Response, db: Session = Depends(get_db)):
    """Reçoit le token de Google, l'échange contre les infos utilisateur."""
    try:
        token = await oauth.google.authorize_access_token(request)
        user_info = token.get('userinfo')
        if not user_info:
            raise HTTPException(status_code=400, detail="Échec de la récupération des infos Google")
        user = userCrud.get_user_by_email(db, user_info.get("email"))
        
        if user :
            send_all_token(user.id, response, db, request)
            return {
                "message": "Connexion Google réussie",
                "user": user
            }
        else :
            new_user = UserCreateGoogle(
                email=user_info.get("email"),
                user_name=user_info.get("name"),
                provider_id=user_info.get("sub")
            )
            user_created = userCrud.create_google_user(db, new_user)
            if user_created:
                send_all_token(user_created.id, response, db, request)
                return {
                    "message": "Compte Google créé et connecté avec succès",
                    "user": user_created
                }
            else:
                raise HTTPException(status_code=500, detail="Erreur lors de la création du compte Google")
            
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Erreur d'authentification : {str(e)}")

@router.post("/logout")
async def logout(request: Request, response: Response, db: Session = Depends(get_db)):
    token = request.cookies.get("refresh_token")
    if token:
        refreshTokenCrud.revoke_refresh_token(db, token)

    response.set_cookie(key="access_token", value="", max_age=0, expires=0, httponly=True, samesite="lax", secure=False)
    response.set_cookie(key="refresh_token", value="", max_age=0, expires=0, httponly=True, path="/", samesite="lax", secure=False)
    request.session.clear() 
    request.cookies.clear()
    print("request.cookies.get('refresh_token'):", request.cookies.get("refresh_token"))
    return {"message": "Déconnexion réussie"}


@router.post("/refresh")
def refresh_access_token(request: Request, response: Response , db: Session = Depends(get_db)):
    refresh_token = request.cookies.get("refresh_token")
    print((f"refresh_token: {refresh_token}"))

    if not refresh_token:
        raise HTTPException(
            status_code=401, detail="Session expirée. Veuillez vous reconnecter."
        )

    try:
        
        payload = decode_token(refresh_token)

        if payload.get("type") != "refresh":
            raise HTTPException(status_code=401, detail="Token invalide")

        user_id = payload.get("sub")
        if not user_id:
            raise HTTPException(status_code=401, detail="Utilisateur introuvable")
        
        if not refreshTokenCrud.is_refresh_token_valid(db, refresh_token):
            raise HTTPException(status_code=401, detail="Token de rafraîchissement invalide ou révoqué")

        send_all_token(user_id, response, db, request)

        return {"status": "success", "message": "Token rafraîchi"}

    except JWTError:
        print(f"Erreur de décodage : {e}")
        raise HTTPException(status_code=401, detail="Session invalide ou expirée")

def send_all_token(user_id, response, db: Session, request: Request = None):
    access_token = create_access_token(subject=user_id)
    refresh_token = create_refresh_token(subject=user_id)

    # révoquer l'ancien token s'il existe
    if request:
        old_token = request.cookies.get("refresh_token")
        if old_token:
            refreshTokenCrud.revoke_refresh_token(db, old_token)

    # sauvegarder le nouveau
    refreshTokenCrud.save_refresh_token(db, user_id, refresh_token)

    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,
        max_age=1800,
        expires=1800,
        samesite="lax",
        secure=False,
    )
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        max_age=604800,
        path="/",
        samesite="lax",
        secure=False,
    )