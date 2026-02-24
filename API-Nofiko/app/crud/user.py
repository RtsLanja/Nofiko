from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate, UserRead, UserCreateGoogle
from typing import Optional
from app.core.security import get_password_hash, verify_password

class UserCRUD:
    def create_user(self, db: Session, user: UserCreate) -> UserRead:
        db_user = User(
            email = user.email,
            user_name = user.user_name,
            is_active = user.is_active,
            hashed_password = get_password_hash(user.password)
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    
    def create_google_user(self, db: Session, user: UserCreateGoogle) -> UserRead:
        db_user = User(
            email = user.email,
            user_name = user.user_name,
            is_active = user.is_active,
            auth_provider = user.auth_provider,
            provider_id = user.provider_id
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user


    def get_user(self,db: Session, user_id: int) -> Optional[UserRead]:
        return db.query(User).filter(User.id == user_id).first()


    def update_user(self, db: Session, user_id: int, user_in: UserUpdate) -> Optional[UserRead]:
        """Met à jour un utilisateur"""
        db_user = self.get_user(db, user_id)
        if not db_user:
            return None

        update_data = user_in.dict(exclude_unset=True)

        # Hacher le nouveau mot de passe si fourni
        if "password" in update_data:
            update_data["hashed_password"] = get_password_hash(update_data["password"])
            del update_data["password"]

        for field, value in update_data.items():
            setattr(db_user, field, value)

        db.commit()
        db.refresh(db_user)
        return db_user


    def delete_user(self, db: Session, user_id: int) -> Optional[UserRead]:
        db_user = self.get_user(db, user_id)
        if db_user:
            db.delete(db_user)
            db.commit()
        return db_user

    def get_user_by_email(self, db: Session, email: str) -> Optional[UserRead]:
        print(f"email {email}")
        """Récupère un utilisateur par son email"""
        return db.query(User).filter(User.email == email).first()
    
    
    def authenticate(self, db: Session, email: str, password: str) -> Optional[UserRead]:
        """Authentifie un utilisateur"""
        
        user = self.get_user_by_email(db, email)
        print(f"user {user}")
        if not user:
            return None
        if not user.is_active:
            return None
        if not verify_password(password, user.hashed_password):
            return None
        return user
    
userCrud = UserCRUD()    