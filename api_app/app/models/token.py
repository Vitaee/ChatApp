from pydantic import BaseModel
from datetime import datetime


class TokenPayload(BaseModel):
    id: str
    exp: datetime


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = 'Bearer'