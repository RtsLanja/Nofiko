import asyncio
import json
from datetime import datetime, timedelta
from typing import List, Dict, Any
from sqlalchemy.orm import Session

from app.crud.profile import profileCrud
from app.crud.job import jobOfferCrud
from .ai_api import analyze_match_with_groq
from app.models.match import JobMatch
from app.utils.pre_filter import pre_filter_jobs

async def run_global_matching(db: Session):
    """Lance le matching pour tous les profils et toutes les offres d'emploi récentes"""
    print(f"Running global matching at {datetime.utcnow()}")
    profiles = profileCrud.get_all_profiles(db)
    recent_jobs = jobOfferCrud.get_all_recent_job_offers(db)
    
    for profile in profiles:
        candidate_jobs = pre_filter_jobs(profile, recent_jobs)
        scored_matches = []
        for job in candidate_jobs:
            match_result = await analyze_match_with_groq(profile, job)
            if match_result["score"] >= 60:
                scored_matches.append({
                    "job_id": job.id,
                    "score": match_result["score"],
                    "explanation": {
                        "points_forts": match_result["points_forts"],
                        "avis_expert": match_result["avis_expert"]
                    }
                })
                
        top_5 = sorted(scored_matches, key=lambda x: x["score"], reverse=True)[:5]            
        
        for matched_job in top_5:
            existing_match = db.query(JobMatch).filter(
                JobMatch.user_id == profile.user_id,
                JobMatch.job_id == matched_job["job_id"]
            ).first()
            
            if existing_match:
                existing_match.score = matched_job["score"]
                existing_match.explanation = matched_job["explanation"]
                existing_match.created_at = datetime.utcnow()
            else:
                new_match = JobMatch(
                    user_id=profile.user_id,
                    job_id=matched_job["job_id"],
                    score=matched_job["score"],
                    explanation=matched_job["explanation"]
                )
                db.add(new_match)
                
    db.commit()            