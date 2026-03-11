from fastapi import (
    APIRouter,
    Depends,
    HTTPException,
    status,
    Response,
    UploadFile,
    File,
)
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.profile import ProfileCreate, ProfileUpdate, ProfileRead
from app.crud.profile import profileCrud
from app.core.security import get_current_user
from app.models.user import User

from app.services.extractor import process_cv
from app.services.ai_api import transform_cv_to_data

router = APIRouter()


@router.get("/", response_model=ProfileRead)
async def get_my_profile(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    profile = profileCrud.get_profile_by_user_id(db, current_user.id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Utilisateur non trouvé")
    return profile

@router.post("/upload-cv")
async def upload_cv(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    if current_user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Non authentifié"
        )
    text, file_path = await process_cv(file)
    print(f"current_user = {current_user}")
    try:
        print(f"Analyzing CV with AI API...")
        ai_data = await transform_cv_to_data(text)
    except Exception as e:
        print(f"Error analyzing CV with AI API: {e}")
        ai_data = {
            "name": "Inconnu",
            "xp": 0,
            "level": "Junior",
            "skills": [],
            "location": "",
        }

    new_profile = ProfileCreate(
        name=ai_data.get("name", "Inconnu"),
        xp=ai_data.get("xp", 0),
        level=ai_data.get("level", "Junior"),
        skills=ai_data.get("skills", []),
        location=ai_data.get("location", "Inconnu"),
        raw_cv_text=text,
        cv_path=file_path,
    )
    check_profile = profileCrud.get_profile_by_user_id(db, current_user.id)
    if check_profile:
        profileCrud.update_profile(db, check_profile.id, new_profile)
    else:
        profileCrud.create_profile(db, new_profile, current_user.id)
    return {"message": "CV analysé avec succès", "preview": new_profile}


@router.put("/", response_model=ProfileRead)
def update_profile(
    profile_update: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user=Depends(get_current_user),
):
    """
    Met à jour un profil.
    """
    profile = profileCrud.update_profile(db, current_user.profile.id, profile_update)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Profil non trouvé"
        )
    return profile


@router.delete("/", status_code=status.HTTP_204_NO_CONTENT)
def delete_profile(
    db: Session = Depends(get_db), current_user=Depends(get_current_user)
):
    """
    Supprime un profil.
    """
    profile = profileCrud.delete_profile(db, current_user.profile.id)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Profil non trouvé"
        )
    return Response(status_code=status.HTTP_204_NO_CONTENT)
