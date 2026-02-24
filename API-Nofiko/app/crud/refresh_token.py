from sqlalchemy.orm import Session
from datetime import datetime, timezone, timedelta
from app.models.refresh_token import RefreshToken

class RefreshTokenCRUD:
    def save_refresh_token(self,db: Session, user_id: str, token: str):
        db_token = RefreshToken(
            token=token,
            user_id=user_id,
            expires_at=datetime.now(timezone.utc) + timedelta(days=7)
        )
        db.add(db_token)
        db.commit()

    def revoke_refresh_token(self,db: Session, token: str):
        print(f"Revoking token: {token}")
        db.query(RefreshToken).filter(RefreshToken.token == token).update({"revoked": True})
        db.commit()

    def is_refresh_token_valid(self,db: Session, token: str) -> bool:
        db_token = db.query(RefreshToken).filter(
            RefreshToken.token == token,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.now(timezone.utc)
        ).first()
        return db_token is not None
    
refreshTokenCrud = RefreshTokenCRUD()    