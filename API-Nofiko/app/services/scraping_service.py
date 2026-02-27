import asyncio
import random
import re
import hashlib
from playwright.async_api import async_playwright
from datetime import datetime, timedelta
from .ai_api import analyze_job_with_groq
from app.schemas.job import JobCreate
from app.crud.job import jobOfferCrud
from app.db.database import SessionLocal
from fastapi import Depends
from app.models.user import User
from app.models.profile import Profile
from app.models.job import JobOffer


BASE_URL = "https://www.portaljob-madagascar.com/emploi/liste/page/"
MONTHS_FR = {
    "Jan": 1,
    "Fév": 2,
    "Mar": 3,
    "Avr": 4,
    "Mai": 5,
    "Juin": 6,
    "Juil": 7,
    "Juill": 7,
    "Août": 8,
    "Sep": 9,
    "Sept": 9,
    "Oct": 10,
    "Nov": 11,
    "Déc": 12,
}


async def scrape_listing(page, page_number: int):
    url = f"{BASE_URL}{page_number}"
    await page.goto(url, wait_until="domcontentloaded", timeout=60000)

    jobs = await page.query_selector_all("article.item_annonce")

    results = []

    for job in jobs:
        title = await job.query_selector("h3 strong")
        link = await job.query_selector("a.description")
        posted_at = await parse_posted_at(job)
        if posted_at and posted_at > datetime.now() - timedelta(days=30):
            fp = hashlib.sha256(f"{link}{title}".encode()).hexdigest()
            results.append(
                {
                    "title": (await title.inner_text()).strip(),
                    "link": await link.get_attribute("href"),
                    "posted_at": posted_at,
                    "fingerprint": fp,
                }
            )
    return results


async def scrape_detail(page, job_url: str):
    await page.goto(job_url, wait_until="domcontentloaded", timeout=60000)

    details = await page.query_selector(".item_tab")

    return {"raw_content": await details.inner_text()}


async def parse_posted_at(item_element):
    try:
        date_container = await item_element.query_selector(".date")
        if not date_container:
            return None

        day_el = await date_container.query_selector("b")
        month_el = await date_container.query_selector(".mois")
        year_el = await date_container.query_selector(".annee")

        if not (day_el and month_el and year_el):
            return None

        day_text = await day_el.inner_text()
        month_text = await month_el.inner_text()
        year_text = await year_el.inner_text()

        month_clean = month_text.replace(".", "").strip()
        month = MONTHS_FR.get(month_clean, 1)
        print(
            f"Parsing date: {day_text} {month_text} {year_text} -> {day_text.strip()}-{month}-{year_text.strip()}"
        )
        return datetime(int(year_text.strip()), month, int(day_text.strip()))
    except Exception:
        print("Erreur lors du parsing de la date de publication.")


async def run_scraper():
    """
    Fonction principale de synchronisation lancée quotidiennement à 16H.
    """
    db = SessionLocal()

    try:
        async with async_playwright() as p:
            # configuration du navigateur
            browser = await p.chromium.launch(headless=True)
            context = await browser.new_context(
                user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
                viewport={"width": 1280, "height": 720},
            )
            
            # 3. bloquer image/css
            await context.route(
                "**/*",
                lambda route: (
                    route.abort()
                    if route.request.resource_type in ["image", "stylesheet", "font"]
                    else route.continue_()
                ),
            )

            page = await context.new_page()
            await page.add_init_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

            page_number = 1

            while True:
                print(f"Scraping Page {page_number}...")
                listings = await scrape_listing(page, page_number)

                if not listings:
                    print("Plus d'annonces à traiter.")
                    break

                for job in listings:
                    job_in_db = jobOfferCrud.get_job_offer_by_fingerprint(
                        db=db, fingerprint=job["fingerprint"]
                    )

                    if job_in_db:
                        print(f"Skip : {job['title']} (Déjà en base)")
                        continue

                    try:
                        print(f"Nouveau poste trouvé : {job['title']}")

                        # simule un comportement humain
                        await asyncio.sleep(random.uniform(1.5, 3.0))

                        details = await scrape_detail(page, job["link"])

                        if not details.get("raw_content"):
                            continue

                        analysis = await analyze_job_with_groq(details["raw_content"])

                        if analysis:
                            job_offer_create = JobCreate(
                                fingerprint=job["fingerprint"],
                                title=job["title"],
                                company=analysis.get("company", "Anonyme"),
                                location=analysis.get("location", "Non spécifiée"),
                                min_xp=analysis.get("min_xp", 0),
                                level_required=analysis.get("level", "Inconnu"),
                                skills_required=analysis.get("skills", []),
                                description=details["raw_content"],
                                raw_url=job["link"],
                                posted_at=job["posted_at"],
                                category=analysis.get("category", "Autre"),
                            )

                            jobOfferCrud.create_job_offer(
                                db=db, job_offer=job_offer_create
                            )
                            print(f"Offre enregistrée avec succès : {job['title']}")

                    except Exception as e:
                        print(f"Erreur sur l'offre '{job['title']}': {e}")
                        continue

                page_number += 1

            await browser.close()
            print("Synchronisation terminée à 100%.")

    except Exception as global_err:
        print(f"Erreur critique du scraper : {global_err}")
    finally:
        db.close()
