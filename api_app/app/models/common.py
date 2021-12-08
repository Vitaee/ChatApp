from datetime import datetime
from pydantic import BaseModel, validator, UUID1
import uuid
from bson import ObjectId


from pydantic.main import Extra

class CreatedAtModel(BaseModel):
    createdAt: datetime = None

    @validator("createdAt", pre=True, always=True)
    def default_time(cls, v, values, **kwargs) -> datetime:
        return datetime.now()


class UpdatedAtModel(BaseModel):
    updatedAt: datetime = None

    @validator("updatedAt", pre=True, always=True)
    def default_time(cls, v, values, **kwargs) -> datetime:
        return datetime.now()


class IDModel(BaseModel):
    id: str

        
    @validator("id", pre=True, always=True)
    def default_id(cls, v, values, **kwargs) -> str:
        return uuid.uuid1().hex


class PyObjectId(ObjectId):
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v):
        if not ObjectId.is_valid(v):
            raise ValueError("Invalid objectid")
        return ObjectId(v)

    @classmethod
    def __modify_schema__(cls, field_schema):
        field_schema.update(type="string")