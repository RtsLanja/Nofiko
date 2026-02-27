from sqlalchemy import Column, String, DateTime , Text, JSON, Integer
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import uuid
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime   

class JobOffer(Base):
    __tablename__ = "job_offer"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
        nullable=False,
    )
    fingerprint = Column(String(64), unique=True, nullable=False)
    title = Column(String(255), nullable=False)
    company = Column(String(255))
    location = Column(String(255))
    min_xp = Column(Integer, default=0)
    level_required = Column(String(50)) # Junior, Confirmé, Senior
    skills_required = Column(JSON) # Liste de compétences
    raw_url = Column(String(500), nullable=False)
    description = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    posted_at = Column(DateTime)
    category = Column(String(100), nullable=False)
