from groq import Groq
import json
from app.core.config import settings
from app.schemas.job import JobRead
from app.schemas.profile import ProfileRead
from typing import Dict, Any

client = Groq(api_key=settings.groq_api_key)
MODELE_NAME = "llama-3.1-8b-instant"

JOB_PROMPT = """
Tu es un expert en analyse de données RH spécialisé sur le marché du travail à Madagascar. 
Ton rôle est d'extraire des informations structurées à partir d'un texte brut de description de poste.

### RÈGLES DE FORMATAGE :
1. Réponds EXCLUSIVEMENT en JSON.
2. Ne fournis aucune introduction ni conclusion.
3. Si une information est manquante, utilise la valeur par défaut spécifiée.

### DÉFINITION DES CHAMPS :
- 'category': Choisis l'un des termes suivants uniquement : [Informatique, BPO/Relation Client, Gestion/Finance, Vente/Marketing, RH, Ingénierie, Autre].
- 'title': Le titre du poste le plus précis.
- 'company': Nom de l'entreprise (Valeur par défaut: 'Anonyme').
- 'location': La ville ou région à Madagascar.
- 'min_xp': UN ENTIER. Si non précisé, mets 0. Si c'est un intervalle (ex: 2 à 4 ans), prends le minimum (2).
- 'level_required': Catégorie stricte basée sur 'min_xp' :
    - 'Junior' (si min_xp < 3)
    - 'Confirmé' (si min_xp entre 3 et 6)
    - 'Senior' (si min_xp >= 7)
- 'skills_required': Liste de 5 à 10 mots-clés techniques (outils, langages, frameworks).
- 'description': Un résumé de 2-3 phrases mettant en avant les responsabilités clés et les exigences du poste.

### LOGIQUE DE CALCUL :
Si les années d'expérience ne sont pas explicites mais qu'on demande 'débutant', min_xp = 0.
Si on demande 'expert', 'responsable' ou 'chef de projet', et que rien n'est écrit, assume min_xp = 5.
"""

CV_PROMPT = """
Tu es un expert en extraction de données RH. 
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


async def transform_cv_to_data(raw_text: str):
    try:

        chat_completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": CV_PROMPT},
                {
                    "role": "user",
                    "content": f"Voici le texte du CV à analyser :\n\n{raw_text}",
                },
            ],
            model=MODELE_NAME,
            response_format={"type": "json_object"},
        )

        return json.loads(chat_completion.choices[0].message.content)
    except Exception as e:
        print(f"Erreur Groq : {e}")
        return None


async def analyze_job_with_groq(raw_text: str):
    try:
        completion = client.chat.completions.create(
            model=MODELE_NAME,
            messages=[
                {"role": "system", "content": JOB_PROMPT},
                {
                    "role": "user",
                    "content": f"Analyse cette offre :\n\n{raw_text[:3500]}",
                },
            ],
            temperature=0.1,
            response_format={"type": "json_object"},
        )

        return json.loads(completion.choices[0].message.content)
    except Exception as e:
        print(f"Erreur critique LLM : {e}")
        return None


async def analyze_match_with_groq(profile: ProfileRead, job: JobRead):
    """Utilisé pendant le MATCHING pour comparer un candidat et une offre."""
    MATCH_PROMPT = f"""
    Tu es un expert en recrutement technique (Senior Recruiter).
    Analyse la correspondance entre ce CANDIDAT et cette OFFRE.
    
    MISSION:
    Même si le titre diffère (ex: Fullstack vs Data), évalue si les compétences techniques 
    du candidat sont transférables. Sois indulgent mais réaliste.

    RÉPONDS UNIQUEMENT AU FORMAT JSON SUIVANT:
    {{
        "score": 0-100,
        "points_forts": ["raison 1", "raison 2"],
        "avis_expert": "Résumé de 15 mots max"
    }}
    """

    try:
        completion = client.chat.completions.create(
            model=MODELE_NAME,
            messages=[
                {"role": "system", "content": MATCH_PROMPT},
                {
                    "role": "user",
                    "content": f"""
                    CANDIDAT:
                    - Details: {profile.raw_cv_text}
                    - Expérience: {profile.xp} ans
                    - Compétences: {", ".join(profile.skills) if profile.skills else "Non spécifiées"}

                OFFRE D'EMPLOI:
                    - Titre: {job.title}
                    - Description: {job.description[:1500]}... (extrait)""",
                },
            ],
            temperature=0.1,
            response_format={"type": "json_object"},
        )
        return json.loads(completion.choices[0].message.content)
    except Exception as e:
        print(f"Erreur critique LLM (Matching) : {e}")
        return {"score": 0, "points_forts": [], "avis_expert": "Erreur technique"}
