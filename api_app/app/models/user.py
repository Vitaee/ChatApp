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
    
class User(BaseModel):
    token : str

class UserInDB(UserBase):
    id : PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    salt: str = ""
    hashed_password : str = ""

    updatedAt: Optional[datetime]
    createdAt: datetime

    

    def check_password(self, password:str):
        return verify_password(self.salt + password, self.hashed_password)

    class Config:
        underscore_attrs_are_private = True
        include_private_fields = True


class UserInResponse(BaseModel):
    user: User

class UserInCreate(UserBase, CreatedAtModel, UpdatedAtModel):
    password: str