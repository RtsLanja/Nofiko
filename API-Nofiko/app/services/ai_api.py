from groq import Groq
import json
from app.core.config import settings

client = Groq(api_key=settings.groq_api_key)

async def transform_cv_to_data(raw_text: str):
    try:
        
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": """Tu es un expert en extraction de données RH. 
                    Ton rôle est de transformer un texte de CV brut en un objet JSON structuré. 
                    Tu dois suivre strictement ces définitions pour chaque champ :
                    
                    1. 'name': Nom complet du candidat.
                    2. 'xp': Un ENTIER représentant le nombre total d'années d'expérience cumulées. 
                    - Si le candidat est stagiaire ou débutant, mets 0 ou 1.
                    - Calcule-le en fonction des dates mentionnées si le total n'est pas explicite.
                    3. 'level': Catégorise le profil selon ces critères uniquement :
                    - 'Junior' (0-2 ans d'expérience)
                    - 'Confirmé' (3-6 ans d'expérience)
                    - 'Senior' (7 ans et plus)
                    4. 'skills': Une liste de chaînes de caractères contenant uniquement les compétences techniques (ex: 'Python', 'React', 'Docker').
                    5. 'location': La ville et le pays de résidence actuelle. Si non trouvé, mets 'Non spécifié'.
                    
                    RÉPONDS UNIQUEMENT AVEC LE JSON, SANS AUCUNE EXPLICATION."""
                },
                {
                    "role": "user",
                    "content": f"Voici le texte du CV à analyser :\n\n{raw_text}"
                }
            ],
            model="llama-3.3-70b-versatile",
            response_format={"type": "json_object"} 
        )
        
        return json.loads(chat_completion.choices[0].message.content)
    except Exception as e:
        print(f"Erreur Groq : {e}")
        return None