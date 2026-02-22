from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from app.core.config import settings

#moteur PG
engine = create_engine(
    settings.database_url,
    pool_pre_ping=settings.db_pool_pre_ping,
    pool_size=settings.db_pool_size,
    max_overflow=settings.db_max_overflow,
    echo=settings.debug 
)

# créer la session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# fonctionn pour obtenir la session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()