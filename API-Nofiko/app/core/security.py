from passlib.context import CryptContext
from fastapi import Request, HTTPException, Depends
from jose import JWTError, jwt
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from typing import Optional, Union, Any
from .config import settings
from fastapi import HTTPException
from typing import Any, Dict
from app.models.user import User
from app.db.database import get_db

# Configuration hachage
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Configuration JWT
SECRET_KEY = settings.secret_key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = settings.access_token_expire_minutes


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie si le mot de passe est correct"""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Hache un mot de passe"""
    return pwd_context.hash(password)


def create_access_token(subject: Union[str, Any]):
    """Crée un token JWT"""

    expire = datetime.now(timezone.utc) + timedelta(minutes=30)

    to_encode = {"exp": expire, "sub": str(subject), "type": "access"}
    
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def create_refresh_token(subject: Union[str, Any]) -> str:
    expires_delta = timedelta(days=7)
    expire = datetime.now(timezone.utc) + expires_delta

    to_encode = {"exp": expire, "sub": str(subject), "type": "refresh"}

    encoded_jwt = jwt.encode(
        to_encode, SECRET_KEY, algorithm=ALGORITHM
    )
    return encoded_jwt


def decode_token(token: str) -> Dict[str, Any]:
    """
    Décode un token JWT et retourne les données.
    Vérifie également le 'purpose' si fourni.
    """
    try:
        print("before")
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        print(f"payload :  {payload}")
        return payload

    except JWTError:
        raise HTTPException(status_code=401, detail="Session expirée")


def get_current_user(request: Request, db: Session = Depends(get_db)) -> Optional[User]:
    """
    Récupère l'utilisateur actuel à partir du token.
    """
    token = request.cookies.get("access_token")

    if not token:
        token = request.headers.get("Authorization")
    
    if not token:
        raise HTTPException(
            status_code=401, detail="Cookie d'authentification manquant"
        )
    if not token.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Format de token invalide")
    token = token.split("Bearer ")[1]
    try:
        payload = decode_token(token)
        user_id: int = payload.get("sub")
        if payload.get("type") != "access":
            raise HTTPException(status_code=401, detail="Token invalide")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Token invalide")
        user = db.query(User).filter(User.id == user_id).first()
        print(f"user = {user}")
        return user
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=401, detail="Token invalide") from e
