from typing import List, Optional
from pydantic import BaseModel, Field
from datetime import datetime
from common.mongoIdObject import PyObjectId

class Room(BaseModel):
    room_name: str
    members: Optional[List] = []
    messages: Optional[List] = []
    last_pinged: datetime = Field(default_factory=datetime.utcnow)
    active: bool = False


class RoomInDB(Room):
    id : PyObjectId = Field(default_factory=PyObjectId, alias="_id")
    date_created: datetime = Field(default_factory=datetime.utcnow)