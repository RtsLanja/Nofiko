from sqlalchemy import Column, String, Boolean, DateTime                                     
from datetime import datetime
from app.db.base_class import Base
import uuid 
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship


class User(Base):
    __tablename__ = "user"
    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        index=True,
        nullable=False,
    )
    user_name = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)

    # null pour sso, sinon on stocke le mot de passe haché
    hashed_password = Column(String, nullable=True)

    is_active = Column(Boolean(), default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    #
    # pour savoir si l'utilisateur vient de Google, Facebook, ou Email
    auth_provider = Column(String(50), default="email")

    # L'ID unique que Google nous envoie (le "sub" dans le token Google)
    provider_id = Column(String(255), unique=True, index=True, nullable=True)

    alert_job = relationship("AlertJob", back_populates="user")
    
    profile = relationship("Profile", back_populates="user", uselist=False)
