from pydantic import BaseModel
from typing import Optional, List
from uuid import UUID
from datetime import datetime

class JobBase(BaseModel):
    title: str
    fingerprint: str
    company: str
    location: str
    min_xp: int
    level_required: str
    skills_required: List[str]
    description: str
    posted_at: Optional[datetime] = None
    category : str
    raw_url: str

class JobCreate(JobBase):
    pass

class JobRead(JobBase):
    id: UUID

    class Config:
        from_attributes = True
