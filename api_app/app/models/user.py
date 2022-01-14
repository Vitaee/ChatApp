from bson.objectid import ObjectId
from pydantic import BaseModel, EmailStr, Field
from models.common import CreatedAtModel, UpdatedAtModel
from typing import List, Optional
from datetime import datetime

from common.security import verify_password
from common.mongoIdObject import PyObjectId


class UserBase(BaseModel):
    username : str
    email : Optional[EmailStr] = None
    image :Optional[str] = ""

class ListUser(BaseModel):
    result: List[UserBase]


class User(BaseModel):
    token : str

class UserInDB(UserBase):
    id : PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    salt: str = ""
    hashed_password : str = ""

    updatedAt: Optional[datetime]
    createdAt: datetime

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
    

    def check_password(self, password:str):
        return verify_password(self.salt + password, self.hashed_password)


class UserInResponse(BaseModel):
    user: User

class UserInRequest(BaseModel):
    username: str
    password: str

    
class UserInCreate(UserBase, CreatedAtModel, UpdatedAtModel):
    password: str