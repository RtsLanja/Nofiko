from sqlalchemy import Column, String, ForeignKey
from sqlalchemy.orm import relationship
from app.db.base_class import Base
import uuid
from sqlalchemy.dialects.postgresql import UUID

class JobOffer(Base):
    __tablename__ = "job_offer"
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
        nullable=False,
    )
    offer_title = Column(String(255), nullable=False, index=True)
    offer_link = Column(String(255), nullable=False, index=True)
    source = Column(String(50), nullable=False, index=True)
    
    id_alert_job = Column(
        UUID(as_uuid=True), ForeignKey("alert_job.id"), nullable=False, index=True
    )
    alert_job = relationship("AlertJob", back_populates="job_offers")
