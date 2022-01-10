from datetime import datetime, timedelta
from typing import Optional
import jwt

from core.config import  SECRET_KEY, ACCESS_TOKEN_EXPIRE_MINUTES

ALGORITHM = "HS256"

def create_access_token(*, data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update( {"exp":expire} )
    encoded_jwt = jwt.encode(to_encode , str(SECRET_KEY), algorithm=ALGORITHM)

    return encoded_jwt