from pydantic import BaseModel
from typing import Optional
from uuid import UUID
from .job import JobRead

class MatchBase(BaseModel):
    user_id: UUID
    job_id: UUID
    score: float
    explanation: Optional[dict] = None
    
class MatchRead(MatchBase):
    id: UUID
    job_offer: JobRead

    class Config:
        from_attributes = True