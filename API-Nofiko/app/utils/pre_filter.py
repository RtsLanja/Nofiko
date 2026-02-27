import re
from app.schemas.profile import ProfileRead

def pre_filter_jobs(profile: ProfileRead, all_jobs):
    relevant_jobs = []
    
    keywords = set(profile.raw_cv_text.lower().split())
    if profile.skills:
        keywords.update([s.lower() for s in profile.skills])

    for job in all_jobs:
 
        desc_lower = job.description.lower()
        match_count = sum(1 for word in keywords if word in desc_lower)

        if match_count >= 2:
            relevant_jobs.append((job, match_count))
            
    # On trie par nombre de mots trouvés et on prend le Top 20
    relevant_jobs.sort(key=lambda x: x[1], reverse=True)
    return [j[0] for j in relevant_jobs[:20]]