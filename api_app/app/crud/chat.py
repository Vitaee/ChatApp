from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request
from fastapi.param_functions import Depends
from motor.motor_asyncio import AsyncIOMotorClient
from api.authentication import get_user
from typing import List
from db.mongosdb import get_database

class SocketManager:
    def __init__(self):
        self.active_connections: List[(WebSocket, str)] = []

    async def connect(self, websocket: WebSocket, user: str):
        await websocket.accept()
        self.active_connections.append((websocket, user))

    def disconnect(self, websocket: WebSocket, user: str):
        self.active_connections.remove((websocket, user))

    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, data):
        for connection in self.active_connections:
            await connection[0].send_json(data)    

manager = SocketManager()

async def insert_room(username, room_name, collection):
    "insert room for both users."
    db: AsyncIOMotorClient = Depends(get_database)
    room = {}
    room["room_name"] = room_name
    user = await get_user(db, field="username", value=username) 
    room["members"] = user if user is not None else ""

    dbroom = RoomInDB(**room)

    response = db["rooms"].insert_one(dbroom.dict())

    res = db["rooms"].find_one( {"_id":response.inserted_id} )
    res["_id"] = str(res["_id"])

    return res

async def get_rooms(username: str = None):
    "get rooms of user has"
    db: AsyncIOMotorClient = Depends(get_database)
    collection = db["rooms"]

    rows = collection.find( {"created_by":username} )

    return rows

async def get_room(room_name : str = None):
    "get room of current user & other user"
    db: AsyncIOMotorClient = Depends(get_database)
    row = db["rooms"].find_one( {"room_name":room_name} )

    if row is not None:
        return row
    else:
        return None

