from db.mongosdb import AsyncIOMotorClient
from typing import Optional, Union
from pydantic import EmailStr
from fastapi import HTTPException
from starlette.status import HTTP_422_UNPROCESSABLE_ENTITY

from core.config import database_name, user_collection_name
from models.user import UserInDB, UserInCreate
from common.security import generate_salt, get_password_hash, verify_password

async def get_user( conn: AsyncIOMotorClient, field: str, value: str) -> Union[UserInDB, bool]:
    user = await conn[database_name][user_collection_name].find_one( { f"{field}" : value } )

    print()
    print("get user response")
    print(user)
    print()
    if user:
        return UserInDB(**user)

    return False

async def check_free_email(conn:AsyncIOMotorClient, email: str = None):

    user_by_email = await get_user(conn, field= "email" , value = email)
    if user_by_email:
        raise HTTPException(
            status_code=HTTP_422_UNPROCESSABLE_ENTITY,
            detail="User with this email already exist!",
        )

async def create_user(conn: AsyncIOMotorClient, user: UserInCreate) -> UserInDB:
    salt = generate_salt()
    hashed_password = get_password_hash(salt + user.password)
    db_user = user.dict()
    db_user['salt'] = salt
    db_user['hashed_password'] = hashed_password
    del db_user['password']

    row = await conn[database_name][user_collection_name].insert_one(db_user)

    return UserInDB(**user.dict())