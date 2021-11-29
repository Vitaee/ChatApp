from pydantic import BaseModel, UUID1, EmailStr, HttpUrl, Field
from models.common import IDModel, CreatedAtModel, UpdatedAtModel
from typing import List, Optional
from datetime import datetime
from fastapi import UploadFile , File

from common.security import verify_password

class UserBase(BaseModel):
    username : str
    email : Optional[EmailStr] = None
    image :Optional[str] = ""
    
class User(BaseModel):
    token : str

class UserInDB(UserBase):
    _id : str
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

class UserInCreate(UserBase, IDModel, CreatedAtModel, UpdatedAtModel):
    password: str