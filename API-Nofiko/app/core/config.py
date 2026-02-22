from pydantic_settings import BaseSettings
import os

class Settings(BaseSettings):
    # Postgres
    database_url: str
    db_pool_size: int = 10
    db_max_overflow: int = 20
    db_pool_pre_ping: bool = True

    #JWT
    secret_key: str              
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # Configuration app 
    app_name: str = "Nofiko"
    debug: bool = True


    class Config:
        env_file = ".env.production" if os.getenv("ENV_STATE") == "prod" else ".env.local"
        extra = "ignore"

settings = Settings()
