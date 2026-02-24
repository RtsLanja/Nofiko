from sqlalchemy import Column, String, Integer, ForeignKey     
from sqlalchemy.dialects.postgresql import JSONB                       
from datetime import datetime
from app.db.base_class import Base
import uuid 
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship


class Profile(Base):
    __tablename__ = "profile"
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
        nullable=False,
    )
    name = Column(String(255), index=True)
    xp = Column(Integer)
    level = Column(String(50)) # Junior ou Senior ...
    skills = Column(JSONB, nullable=True, server_default='[]')
    location = Column(String(255))# tana
    user_id = Column(UUID(as_uuid=True), ForeignKey("user.id"), nullable=False)
    raw_cv_text = Column(String) # pour stocker le texte brut du CV après extraction
    cv_path = Column(String)

    user = relationship("User", back_populates="profile")