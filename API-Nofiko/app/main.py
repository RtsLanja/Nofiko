from fastapi import FastAPI
from app.api.v1.user import router as user_router
from app.api.v1.scrape_job import router as scrape_job_router
from app.api.v1.auth import router as auth_router

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Serveur de Scraping Opérationnel"}



app.include_router(user_router, prefix="/api/v1/user", tags=["user"])
app.include_router(scrape_job_router, prefix="/api/v1/scrape_job", tags=["scrape_job"])
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])