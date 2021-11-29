from datetime import datetime, timedelta
from typing import Optional
import jwt
from fastapi import Depends, Header
from jwt import PyJWTError
from starlette.exceptions import HTTPException
from starlette.status import HTTP_403_FORBIDDEN, HTTP_404_NOT_FOUND
from fastapi.security import OAuth2PasswordBearer

from crud.user import get_user
from db.mongosdb import AsyncIOMotorClient, get_database
from models.token import TokenPayload
from models.user import User
from core.config import JWT_TOKEN_PREFIX, SECRET_KEY, ACCESS_TOKEN_EXPIRE_MINUTES

ALGORITHM = "HS256"


def auth_token( Authorization: str = Header(...)) -> str:
    token_prefix, token = Authorization.split(" ")

    if token_prefix != JWT_TOKEN_PREFIX:
        raise HTTPException( status_code=HTTP_403_FORBIDDEN, detail= "Token information error!")

    return token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/user/login")

async def get_current_user(db: AsyncIOMotorClient = Depends(get_database), token: str = Depends(oauth2_scheme)) -> User:
    try:
        payload = jwt.decode(token , str(SECRET_KEY), algorithms=[ALGORITHM])
        token_data = TokenPayload(**payload)

    except PyJWTError:
        
        raise HTTPException(status_code=HTTP_403_FORBIDDEN, detail="Invalid authorization information!")
    
    print(token_data)
    print(token_data.id)
    dbuser = await get_user(db, field = "_id" , value = token_data.id)

    if not dbuser:
        raise HTTPException(status_code=HTTP_404_NOT_FOUND, detail="User doest not exist!")

    user = User(**dbuser.dict(), token = token)
    return user 

def get_current_user_authorizer(*, required: bool = True):
    if required:
        return get_current_user

def create_access_token(*, data: dict, expires_delta: Optional[timedelta] = None):
    print()
    print("acces token func")
    print(data)
    print()
    
    to_encode = data.copy()

    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    
    else:
        expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)

    to_encode.update( {"exp":expire} )
    encoded_jwt = jwt.encode(to_encode , str(SECRET_KEY), algorithm=ALGORITHM)

    return encoded_jwt