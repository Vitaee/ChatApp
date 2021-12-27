import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect, Request
from fastapi.param_functions import Depends
from motor.motor_asyncio import AsyncIOMotorClient
from api.authentication import get_user
from typing import List
from models.room import RoomInDB
from db.mongosdb import get_database
from common.mongoIdObject import PyObjectId
from fastapi.encoders import jsonable_encoder

class SocketManager:
    def __init__(self):
        self.active_connections: List[(WebSocket, str)] = []

    async def connect(self, websocket: WebSocket, room:str, user: str):
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

async def insert_room(db: AsyncIOMotorClient, username, room_name):
    "insert room for both users."
    room = {}
    room["room_name"] = room_name
    user = await get_user(db, field="username", value=username) 
    room["members"] = [  user.username ] if user is not None else ""
    
    dbroom = RoomInDB(**room)

    response = await db["chat-app"]["rooms"].insert_one(dbroom.dict())
    return response.inserted_id

async def get_rooms(db: AsyncIOMotorClient, username: str = None):
    "get rooms of user has"
    collection = await db["chat-app"]["rooms"]

    rows = await collection.find( {"created_by":username} )

    return rows

async def get_room(db: AsyncIOMotorClient, room_name : str = None):
    "get room of current user & other user"
    row = await db["chat-app"]["rooms"].find_one( {"room_name":room_name} )

    if row is not None:
        return row
    else:
        return None

async def upload_message_to_room(db:AsyncIOMotorClient, data) -> bool:
    message_data = json.loads(data) 

    try:
        room = await get_room(message_data["room_name"])
        user = await get_user(field="username", value = message_data["user"]["username"])
        message_data["user"] = user
        message_data.pop("room_name", None)
        await db["chat-app"]["rooms"].update_one( {"_id": room["_id"]}, {"$push": {"messages":message_data}} )
        return True

    except Exception as e:
        return False