from fastapi import APIRouter, BackgroundTasks , Depends
from app.services.scraping import run_job_scraper
from typing import Optional
from app.core.security import get_current_user
from app.models.user import User


router = APIRouter()

@router.get("/")
async def trigger_manual_scrape(q: Optional[str] = "Développeur", user: User = Depends(get_current_user)): 
    results = await run_job_scraper(q)
    return {"status": "success", "data": results}

@router.post("/auto-scan")
async def schedule_scan(background_tasks: BackgroundTasks, q: Optional[str] = "Développeur Mobile", user: User = Depends(get_current_user)):
    """Lancer le scan en tâche de fond pour ne pas bloquer l'API"""
    background_tasks.add_task(run_job_scraper, q)
    return {"message": "Le scan a été lancé en arrière-plan."}