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

    async def connect(self, websocket: WebSocket, room:str,):
        await websocket.accept()
        self.active_connections.append((websocket,room))

    def disconnect(self, websocket: WebSocket, room:str):
        try:
            self.active_connections.remove((websocket, room))
        except: 
            pass
    async def send_personal_message(self, message: str, websocket: WebSocket):
        await websocket.send_text(message)

    async def broadcast(self, data):
        print("\n [LOG] from broadcast function in SocketManager: \t", data, "\n")
        for connection in self.active_connections:
            await connection[0].send_json(data)    

manager_for_room = SocketManager()
manager_for_home = SocketManager()
async def insert_room(db: AsyncIOMotorClient, username, room_name):
    "insert room for both users."
    room = {}
    room["room_name"] = room_name
   
   
    
    
    user = await get_user(db, field="username", value=username) 
    check_room = await db["chat-app"]["rooms"].count_documents(  {"room_name": room_name}  )
    if ( check_room > 0 ):
        user_to_room = await get_room(db, room_name)
        username_list = [m for m in user_to_room["members"]]
        
        if user.username not in username_list:

            await db["chat-app"]["rooms"].update_one({"room_name":room["room_name"]}, { "$push": {"members": user.username } })
        return ""
    else: 
        room["members"] = [  user.username ] if user is not None else ""
        room["created_by"] = user.username
        room["target_user"] = ""
        dbroom = RoomInDB(**room)
        dbroom.dict().pop(f"{id}", None)
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
    message_data = data[0]
    print("[LOG] uploading message ", message_data)
    try:
        room = await get_room(db, message_data['room_name'])
        user = await get_user(db, field="username", value = message_data['user'])

        
        message_data['user'] = jsonable_encoder(user.username)
        message_data.pop('room_name', None)
        await db["chat-app"]["rooms"].update_one( {"_id": room["_id"]}, {"$push": {"messages":message_data}} )
        if not room["target_user"]:
            print("[LOG] not target user running another db query.")
            await db["chat-app"]["rooms"].update_one( {"_id": room["_id"]}, {"$set": {"target_user":message_data["target_user"]}} )
        return True

    except Exception as e:
        print("An error accured while uploading message to db  " ,e)
        return False