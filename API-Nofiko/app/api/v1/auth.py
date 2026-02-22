from fastapi import APIRouter, Response, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from jose import JWTError

from app.core.security import create_access_token, create_refresh_token, decode_token
from app.db.database import get_db
from app.crud.user import userCrud

router = APIRouter()


@router.post("/login")
def login_user(
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

    access_token = create_access_token(subject=user.id)
    refresh_token = create_refresh_token(subject=user.id)

   
    response.set_cookie(
        key="access_token",
        value=f"Bearer {access_token}",
        httponly=True,
        max_age=1800,
        expires=1800,
        samesite="lax",
        secure=False,  # secure = true en prod
    )
    response.set_cookie(
        key="refresh_token",
        value=refresh_token,
        httponly=True,
        max_age=604800,
        path="/api/v1/auth/refresh",
    )

    return {"message": "Connexion réussie"}


@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie(
        key="access_token",
        httponly=True,
        samesite="lax",
        secure=False,  # secure = True en prod
    )
    response.delete_cookie(
        key="refresh_token", samesite="lax", httponly=True, path="/api/v1/auth/refresh"
    )
    return {"message": "Déconnexion réussie"}


@router.post("/refresh")
def refresh_access_token(request: Request, response: Response):
    refresh_token = request.cookies.get("refresh_token")
    
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

        new_access_token = create_access_token(subject=user_id)

        response.set_cookie(
            key="access_token",
            value=f"Bearer {new_access_token}",
            httponly=True,
            max_age=1800,  # 30 min
            samesite="lax",
            secure=False,  # secure = True en prod
        )
        new_refresh_token = create_refresh_token(subject=user_id)

        response.set_cookie(
            key="refresh_token",
            value=new_refresh_token,
            httponly=True,
            max_age=604800,  # 7 jours
            samesite="lax",
            secure=False,  # secure = True en prod
        )

        return {"status": "success", "message": "Token rafraîchi"}

    except JWTError:
        print(f"Erreur de décodage : {e}")
        raise HTTPException(status_code=401, detail="Session invalide ou expirée")
