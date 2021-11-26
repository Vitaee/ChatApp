from datetime import datetime
from pydantic import BaseModel, validator, UUID1
import uuid

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
    id: str = ''

    @validator("id", pre=True, always=True)
    def default_id(cls, v, values, **kwargs) -> str:
        return uuid.uuid1().hex