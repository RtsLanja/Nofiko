import asyncio
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from app.services.scraping_service import run_scraper
from app.services.matcher import run_global_matching
from app.db.database import SessionLocal


async def run_matching_job():
    db = SessionLocal()
    try:
        await run_global_matching(db)
    finally:
        db.close()


def start_scheduler():
    scheduler = AsyncIOScheduler()
  
    scheduler.add_job(run_scraper, trigger="cron", hour=13, minute=0)

    scheduler.add_job(run_matching_job, trigger="cron", hour=16, minute=0)

    scheduler.add_job(run_matching_job, trigger="cron", hour=23, minute=0)

    scheduler.start()