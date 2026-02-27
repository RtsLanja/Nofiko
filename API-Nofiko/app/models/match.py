from sqlalchemy import Column, Float, ForeignKey, JSON, DateTime
from sqlalchemy.dialects.postgresql import UUID
from app.db.base_class import Base
from datetime import datetime
import uuid

class JobMatch(Base):
    __tablename__ = "job_match"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("user.id", ondelete="CASCADE"))
    job_id = Column(UUID(as_uuid=True), ForeignKey("job_offer.id", ondelete="CASCADE"))
    score = Column(Float)
    explanation = Column(JSON) 
    created_at = Column(DateTime, default=datetime.utcnow)