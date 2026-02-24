import google.generativeai as genai
from app.core.config import settings

genai.configure(api_key=settings.gemeni_api_key)

print("--- DIAGNOSTIC DES MODÈLES ---")
try:
    models = genai.list_models()
    found_flash = False
    for m in models:
        print(f"Modèle trouvé : {m.name}")
        if "gemini-1.5-flash" in m.name:
            found_flash = True
    
    if found_flash:
        print("\n✅ Le modèle Flash est bien présent dans votre liste.")
    else:
        print("\n❌ Le modèle Flash est INTROUVABLE pour cette clé.")
except Exception as e:
    print(f"❌ Erreur lors du listing : {e}")