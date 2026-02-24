from pydantic import BaseModel, EmailStr, validator
from typing import Optional
from datetime import datetime
from uuid import UUID

# Base commune
class UserBase(BaseModel):
    email: EmailStr
    user_name: str
    is_active: bool = True
    

# Pour créer un utilisateur
class UserCreate(UserBase):
    password: str
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 6:
            raise ValueError('Le mot de passe doit contenir au moins 6 caractères')
        return v
    
 # Pour créer un utilisateur via Google OAuth
class UserCreateGoogle(BaseModel):
    email: EmailStr
    user_name: str
    auth_provider: str = "google"
    provider_id: str
    is_active: bool = True   
    

# Pour mettre à jour un utilisateur
class UserUpdate(BaseModel):
    user_name: Optional[str] = None
    password: Optional[str] = None
    is_active: Optional[bool] = None
    
    @validator('user_name')
    def validate_user_name(cls, v):
        if len(v) < 3:
            raise ValueError('Le nom d\'utilisateur doit contenir au moins 3 caractères')
        return v

class UserRead(UserBase):
    id: UUID
    created_at: datetime
    class Config:
        from_attributes = True 
        
class UserForChangePassword(BaseModel):
    old_password: str
    new_password: str       

