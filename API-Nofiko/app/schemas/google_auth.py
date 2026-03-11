from pydantic import BaseModel

# Schéma Pydantic
class GoogleMobileToken(BaseModel):
    id_token: str