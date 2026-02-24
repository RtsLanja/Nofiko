from pydantic import BaseModel, EmailStr, validator
from typing import Optional, List
from datetime import datetime
from uuid import UUID

from .user import UserRead

class ProfileBase(BaseModel):
    name: str
    xp: int
    level: str
    skills: List[str]
    location: str
    raw_cv_text: Optional[str] = None
    cv_path: str

class ProfileCreate(ProfileBase):
    pass

class ProfileUpdate(ProfileBase):
    pass

class ProfileRead(ProfileBase):
    id: UUID
    user_id: UUID
    user: Optional[UserRead] = None

    class Config:
        from_attributes = True
