from fastapi import FastAPI
from app.api.v1.user import router as user_router
from app.api.v1.scrape_job import router as scrape_job_router
from app.api.v1.auth import router as auth_router
from app.api.v1.profile import router as profile_router
from starlette.middleware.sessions import SessionMiddleware
from app.models.user import User  
from app.models.alert_job import AlertJob
from app.models.job import JobOffer
from app.models.profile import Profile
from app.models.refresh_token import RefreshToken


from app.core.config import settings

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Serveur de Scraping Opérationnel"}

app.add_middleware(SessionMiddleware, secret_key=settings.secret_key)

app.include_router(user_router, prefix="/api/v1/user", tags=["user"])
app.include_router(scrape_job_router, prefix="/api/v1/scrape_job", tags=["scrape_job"])
app.include_router(auth_router, prefix="/api/v1/auth", tags=["auth"])
app.include_router(profile_router, prefix="/api/v1/profile", tags=["profile"])