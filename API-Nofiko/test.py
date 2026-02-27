import asyncio
from app.services.matcher import run_global_matching
from app.db.database import SessionLocal

if __name__ == "__main__":
    try:
        # asyncio.run initialise la boucle et execute la coroutine
        asyncio.run(run_global_matching(SessionLocal()))
    except KeyboardInterrupt:
        print("\n🛑 Match interrompu par l'utilisateur.")
    except Exception as e:
        print(f"💥 Erreur lors de l'exécution : {e}")