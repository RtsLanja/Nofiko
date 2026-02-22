import asyncio
from playwright.async_api import async_playwright


async def get_hellowork_jobs(page, query):
    url = f"https://www.hellowork.com/fr-fr/emploi/recherche.html?k={query}"
    await page.goto(url, wait_until="domcontentloaded")
    cards = await page.query_selector_all('li[data-id-storage-target="item"]')

    results = []
    for card in cards:
        title_el = await card.query_selector("h3 p.tw-typo-l")
        job_id = await card.get_attribute("data-id-storage-item-id")
        if title_el and job_id:
            results.append(
                {
                    "title": (await title_el.inner_text()).strip(),
                    "link": f"https://www.hellowork.com/fr-fr/emplois/{job_id}.html",
                    "source": "Hellowork",
                }
            )
    return results


async def get_portaljob_jobs(page, query):
    clean_query = query.replace(" ", "-")
    url = f"https://www.portaljob-madagascar.com/search/advanced/res/1/motcle/{clean_query}/"
    await page.goto(url, wait_until="domcontentloaded")

    cards = await page.query_selector_all("article.item_annonce")
    results = []
    for card in cards:
        title_el = await card.query_selector("h3 strong")
        link_el = await card.query_selector("a.description")
        if title_el and link_el:
            results.append(
                {
                    "title": (await title_el.inner_text()).strip(),
                    "link": await link_el.get_attribute("href"),
                    "source": "PortalJob",
                }
            )
    return results


async def run_job_scraper(search_query: str):
    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        context = await browser.new_context(
            viewport={"width": 1920, "height": 1080},
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36",
        )
        page = await context.new_page()

        all_jobs = []

        try:
            print("Scraping Hellowork...")
            all_jobs.extend(await get_hellowork_jobs(page, search_query))

            print("Scraping PortalJob...")
            all_jobs.extend(await get_portaljob_jobs(page, search_query))

        except Exception as e:
            print(f"Erreur globale : {e}")
        finally:
            await browser.close()

        print(f"Total : {len(all_jobs)} offres.")
        return all_jobs
