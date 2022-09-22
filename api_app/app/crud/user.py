from fastapi.encoders import jsonable_encoder
from db.mongosdb import AsyncIOMotorClient
from typing import Optional, Union
from pydantic import EmailStr
from fastapi import HTTPException
from starlette.status import HTTP_422_UNPROCESSABLE_ENTITY

from core.config import DB_NAME, USER_COLLECTION_NAME
from models.user import UserInDB, UserInCreate
from common.security import generate_salt, get_password_hash, verify_password

async def get_user( conn: AsyncIOMotorClient, field: str, value: str) -> Union[UserInDB, bool]:
    user = await conn[DB_NAME][USER_COLLECTION_NAME].find_one( { f"{field}" : value } )
    
    if user:
        return UserInDB(**user)

    return False

async def get_filtered_users(conn: AsyncIOMotorClient, query: str):
    users =  await conn[DB_NAME][USER_COLLECTION_NAME].aggregate( [{'$match':{'username':{ "$regex":f'{query}'}}}] ).to_list(length=50)
    if users:
        return { "result": users }
    else:
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

    row = await conn[DB_NAME][USER_COLLECTION_NAME].insert_one(db_user)

    return UserInDB(**user.dict())

async def get_messages(conn: AsyncIOMotorClient, room_name:str):
    row = await conn[DB_NAME]["rooms"].find_one({"room_name":room_name})
    if row:
        return jsonable_encoder(row["messages"])
    else:
        return None