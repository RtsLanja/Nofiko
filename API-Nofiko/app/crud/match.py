from sqlalchemy.orm import Session
from typing import Optional

from app.models.match import JobMatch
from app.schemas.match import MatchRead
from app.crud.job import jobOfferCrud

class MatchCRUD:
    
    def get_match(self, db: Session, match_id) -> Optional[MatchRead]:
        res = db.query(JobMatch).filter(JobMatch.id == match_id).first()
        if res:
            res.job_offer = jobOfferCrud.get_job_offer(db, res.job_id) if res.job_id else None
        return res
    
    def get_matches_for_user(self, db: Session, user_id) -> list[MatchRead]:
        res = db.query(JobMatch).filter(JobMatch.user_id == user_id).order_by(JobMatch.score.desc()).all()
        for match in res:
            match.job_offer = jobOfferCrud.get_job_offer(db, match.job_id) if match.job_id else None
        return res
    
matchCrud = MatchCRUD()    