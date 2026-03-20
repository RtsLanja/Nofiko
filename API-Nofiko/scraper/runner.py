import asyncio
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.services.scraping_service import run_scraper
from app.services.matcher import run_global_matching
from app.db.database import SessionLocal


def start_scheduler():

    scheduler = AsyncIOScheduler()

    
    scheduler.add_job(
        run_scraper,  
        trigger="cron",
        hour=15,
        minute=0
    )

    scheduler.add_job(
        lambda: run_global_matching(SessionLocal()),
        trigger="cron",
        hour=16,
        minute=0
    )

    scheduler.start()