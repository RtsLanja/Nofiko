from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import uuid
from sqlalchemy.dialects.postgresql import UUID


class AlertJob(Base):
    __tablename__ = "alert_job" #
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
        nullable=False,
    )
    job_name = Column(String(255), nullable=False, index=True)
    is_active = Column(String(5), default="true")
    user_id = Column(
        UUID(as_uuid=True), ForeignKey("user.id"), nullable=False, index=True
    )
    user = relationship("User", back_populates="alert_job")
    job_offers = relationship("JobOffer", back_populates="alert_job")
