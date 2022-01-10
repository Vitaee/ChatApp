from fastapi import APIRouter, Header
from fastapi.param_functions import Depends
from motor.motor_asyncio import AsyncIOMotorClient
from starlette.websockets import WebSocket, WebSocketDisconnect, WebSocketState
from crud.user import get_messages
from db.mongosdb import get_database
from crud.chat import insert_room, manager, upload_message_to_room
import json
router = APIRouter()

@router.websocket("/chat/{room_name}/")
async def websocket_endpoint(db: AsyncIOMotorClient = Depends(get_database), websocket: WebSocket = WebSocket, room_name: str = None, current_user: str = Header(None)):
    print("\n\t", current_user , " <-- connected.\n")
    current_username = current_user
    try:
        await manager.connect(websocket, room_name)
        await insert_room(db, current_username, room_name)
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



