from pydantic import BaseModel, UUID1, EmailStr, HttpUrl, Field
from models.common import IDModel, CreatedAtModel, UpdatedAtModel
from typing import List, Optional
from datetime import datetime
from fastapi import UploadFile , File

from common.security import verify_password

class UserBase(BaseModel):
    username : str
    email : Optional[EmailStr] = None
    image :Optional[bytes] = ""
    #image : Optional[UploadFile] = File(...)
    
class User(BaseModel):
    token : str

class UserInDB(UserBase):
    _id : str = ""
    salt: str = ""
    hashed_password : str = ""

    updatedAt: Optional[datetime]
    createdAt: datetime

    def check_password(self, password:str):
        return verify_password(self.salt + password, self.hashed_password)

class UserInResponse(BaseModel):
    user: User

class UserInCreate(UserBase, IDModel, CreatedAtModel, UpdatedAtModel):
    password: str