from fastapi import APIRouter, Header
from fastapi.param_functions import Depends
from motor.motor_asyncio import AsyncIOMotorClient
from starlette.responses import JSONResponse
from starlette.websockets import WebSocket, WebSocketDisconnect, WebSocketState
from core.auth_bearer import JwtBearer
from crud.user import get_messages
from db.mongosdb import get_database
from crud.chat import insert_room, manager, upload_message_to_room
from models.user import User
import json
from starlette.status import HTTP_200_OK, HTTP_404_NOT_FOUND
router = APIRouter()

@router.websocket("/chat/{room_name}/")
async def websocket_endpoint(db: AsyncIOMotorClient = Depends(get_database), websocket: WebSocket = WebSocket, room_name: str = None, users: str = Header(None)):
    print("\n\t", users["Current-User"] , " <-- connected.\n")
    current_username = users["Current-User"]
    try:
        await manager.connect(websocket, room_name)
        await insert_room(db, current_username, users["Target-User"],room_name)
        all_messages = await get_messages(db, room_name)
        await manager.broadcast(all_messages)

        # wait for messages
        while True:
            if websocket.application_state == WebSocketState.CONNECTED:
                data = await websocket.receive_text()
                message_data = json.loads(data)
               
                if "type" in message_data and message_data["type"] == "dismissal":
                    await manager.disconnect(websocket, room_name)
                    break
                else:
                    await upload_message_to_room(db,message_data)
                    all_messages.append(message_data[0])
                    await manager.broadcast(all_messages)
            else:
                await manager.connect(websocket, room_name)

    except Exception as e:
        print("\n")
        print("\tcould not connect --> ", e)
        print(type(e).__name__, e.args, e.__repr__)
        print()
        manager.disconnect(websocket, room_name)

@router.websocket("/chats")
async def listen_messages(db: AsyncIOMotorClient = Depends(get_database), websocket: WebSocket = WebSocket, current_user: str = Header(None)):
    """
    This function will listen users and check if they send message other users.
    İf it is send notify to target user.
    """
    print()
    print("\t", current_user, " <-- connected")
    print()
    # check if message sended to this user.

    # message count: int = 0 
    # target user: str = "Can"

@router.get("/user/chats/")
async def get_messages_of_user(db: AsyncIOMotorClient =  Depends(get_database), current_user: User = Depends(JwtBearer())):
    """This function will return current user chats with other ones."""
    chat_response = { "chats": [] }
    to_target_username = await db["chat-app"]["rooms"].find_one( { 'created_by' : current_user  } )
    try:
        target_user = to_target_username["target_user"]

        get_target_user = await db["chat-app"]["users"].find_one( {'username':target_user} )

        to_response = {}

        to_response["recvUsername"] = target_user
        if to_target_username["messages"][-1]["user"] == target_user:
            # target user's last message
            to_response["lastMessage"] = to_target_username["messages"][-1]["data"]
        else:
            # your last message
            to_response["lastMessage"] = to_target_username["messages"][-1]["data"]

        to_response["lastMessageDate"] = to_target_username["messages"][-1]["date_sended"]
        to_response["message_seen_by_tuser"] = to_target_username["messages"][-1]["message_seen_by_tuser"]
        to_response["currentUser"] = current_user
        to_response["profilePic"] = get_target_user["image"]

        chat_response["chats"].append(to_response)

        return JSONResponse(status_code=HTTP_200_OK, content = chat_response)
    except:
        return JSONResponse(status_code=HTTP_404_NOT_FOUND, content={"error":"Not found!"})
