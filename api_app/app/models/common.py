from datetime import datetime
from pydantic import BaseModel, validator
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
