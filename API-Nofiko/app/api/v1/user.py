from fastapi import APIRouter, Depends, HTTPException, status , Response
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.user import UserCreate, UserUpdate, UserRead
from app.crud.user import userCrud
from app.models.user import User
from app.core.security import get_current_user

router = APIRouter()

@router.post("/", response_model=UserRead, status_code=status.HTTP_201_CREATED)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Crée un nouvel utilisateur.
    """
    existing_user = userCrud.get_user_by_email(db, user.email)
    if existing_user:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Email déjà utilisé")
    
    return userCrud.create_user(db, user)

@router.get("/", response_model=UserRead)
def get_user(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Récupère un utilisateur par son ID.
    """
    user = userCrud.get_user(db, current_user.id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur non trouvé")
    return user

@router.put("/", response_model=UserRead)
def update_user(user_update: UserUpdate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Met à jour un utilisateur.
    """
    user = userCrud.update_user(db, current_user.id, user_update)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur non trouvé")
    return user

@router.delete("/", status_code=status.HTTP_204_NO_CONTENT)
def delete_user(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Supprime un utilisateur.
    """
    user = userCrud.delete_user(db, current_user.id)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur non trouvé")
    return Response(status_code=status.HTTP_204_NO_CONTENT)
