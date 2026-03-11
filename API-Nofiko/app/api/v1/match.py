from fastapi import APIRouter, Depends, HTTPException, status , Response
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.schemas.match import MatchRead
from app.crud.match import matchCrud
from app.core.security import get_current_user

router = APIRouter()

@router.get("/my-matches", response_model=list[MatchRead])
def get_my_matches(db: Session = Depends(get_db), current_user = Depends(get_current_user)):
    """
    Récupère les offres d'emploi correspondant au profil de l'utilisateur connecté.
    """
    matches = matchCrud.get_matches_for_user(db, current_user.id)
    if not matches:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Aucun match trouvé pour cet utilisateur")
    return matches