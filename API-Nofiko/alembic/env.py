from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
from dotenv import load_dotenv
from app.core.config import settings

# 1. Chargement de l'environnement
load_dotenv()

# 2. Imports des modèles pour la détection
from app.db.base import Base 
from app.models.user import User
from app.models.job import JobOffer
from app.models.alert_job import AlertJob   

config = context.config

# 3. Configuration de l'URL SQLAlchemy
database_url = settings.database_url
if database_url:
    if database_url.startswith("postgres://"):
        database_url = database_url.replace("postgres://", "postgresql://", 1)
    config.set_main_option("sqlalchemy.url", database_url)

if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata 

print("--- DEBUG ALEMBIC ---")
print(f"Tables détectées : {Base.metadata.tables.keys()}")
print(f"URL utilisée : {database_url.split('@')[-1] if database_url else 'AUCUNE'}")

# --- LES FONCTIONS MANQUANTES ---

def run_migrations_offline() -> None:
    """Mode hors-ligne : génère du SQL sans se connecter à la DB."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    """Mode en ligne : se connecte à Neon et exécute le SQL."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, 
            target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

# --- DÉMARRAGE DU PROCESSUS ---
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()