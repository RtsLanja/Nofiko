from sqlalchemy.orm import Session
from typing import Optional

from app.models.profile import Profile
from app.schemas.profile import ProfileCreate, ProfileUpdate, ProfileRead
from.user import UserCRUD


class ProfileCRUD:
    
    def create_profile(self, db: Session, profile: ProfileCreate, user_id) -> ProfileRead:
        db_profile = Profile(
            name = profile.name,
            xp = profile.xp,
            level = profile.level,
            skills = profile.skills,
            location = profile.location,
            raw_cv_text = profile.raw_cv_text,
            cv_path = profile.cv_path,
            user_id = user_id
        )
        db.add(db_profile)
        db.commit()
        db.refresh(db_profile)
        return db_profile

    def get_profile(self,db: Session, profile_id) -> Optional[ProfileRead]:
        res = db.query(Profile).filter(Profile.id == profile_id).first()
        res.user = UserCRUD().get_user(db, res.user_id) if res else None
        return res
    
    def get_profile_by_user_id(self, db: Session, user_id) -> Optional[Profile]:
        res = db.query(Profile).filter(Profile.user_id == user_id).first()
        return res

    def update_profile(self, db: Session, profile_id, profile_in: ProfileUpdate) -> Optional[ProfileRead]:
        """Met à jour un profil"""
        db_profile = self.get_profile(db, profile_id)
        if not db_profile:
            return None

        update_data = profile_in.dict(exclude_unset=True)

        for field, value in update_data.items():
            setattr(db_profile, field, value)

        db.commit()
        db.refresh(db_profile)
        return db_profile

    def delete_profile(self, db: Session, profile_id) -> Optional[ProfileRead]:
        """Supprime un profil"""
        db_profile = self.get_profile(db, profile_id)
        if not db_profile:
            return None

        db.delete(db_profile)
        db.commit()
        return db_profile
    
profileCrud = ProfileCRUD()    