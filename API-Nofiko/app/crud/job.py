from sqlalchemy.orm import Session
from typing import Optional

from app.models.job import JobOffer
from app.schemas.job import JobCreate, JobRead

class JobOfferCRUD:

    def create_job_offer(self, db: Session, job_offer: JobCreate) -> JobRead:
        db_job_offer = JobOffer(
            fingerprint=job_offer.fingerprint,
            title=job_offer.title,
            company=job_offer.company,
            location=job_offer.location,
            min_xp=job_offer.min_xp,
            level_required=job_offer.level_required,
            skills_required=job_offer.skills_required,
            description=job_offer.description,
            raw_url=job_offer.raw_url,
            posted_at = job_offer.posted_at,
            category = job_offer.category
        )
        db.add(db_job_offer)
        db.commit()
        db.refresh(db_job_offer)
        return db_job_offer

    def get_job_offer(self, db: Session, job_offer_id) -> Optional[JobRead]:
        return db.query(JobOffer).filter(JobOffer.id == job_offer_id).first()
    
    def get_job_offer_by_fingerprint(self, db: Session, fingerprint: str) -> Optional[JobRead]:
        return db.query(JobOffer).filter(JobOffer.fingerprint == fingerprint).first()
    
    def get_all_recent_job_offers(self, db: Session, limit: int = 200) -> list[JobRead]:
        return db.query(JobOffer).order_by(JobOffer.posted_at.desc()).limit(limit).all()

jobOfferCrud = JobOfferCRUD()    