from pydantic import BaseModel
from datetime import datetime


class TokenPayload(BaseModel):
    _id: str
    exp: datetime
    class Config:
        include_private_fields = True
        underscore_attrs_are_private = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = 'Bearer'