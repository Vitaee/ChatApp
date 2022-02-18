from fastapi import APIRouter, Header
from fastapi.param_functions import Depends
from motor.motor_asyncio import AsyncIOMotorClient
from starlette.responses import JSONResponse
from starlette.websockets import WebSocket, WebSocketDisconnect, WebSocketState
from common.fcmnotif import send_notification
from core.auth_bearer import JwtBearer
from crud.user import get_messages
from db.mongosdb import get_database
from crud.chat import insert_room, manager_for_room,manager_for_home, upload_message_to_room
from models.user import User
import json
from fastapi.encoders import jsonable_encoder

from starlette.status import HTTP_200_OK, HTTP_404_NOT_FOUND
router = APIRouter()

@router.websocket("/chat/{room_name}/")
async def websocket_endpoint(db: AsyncIOMotorClient = Depends(get_database), websocket: WebSocket = WebSocket, room_name: str = None, current_user: str = Header(None)):
    print("\n\t", current_user , " <-- connected.\n")
    current_username = current_user
    try:
        await manager_for_room.connect(websocket, room_name)
        await insert_room(db, current_username, room_name)
        all_messages = await get_messages(db, room_name)
        await manager_for_room.broadcast(all_messages)

        # wait for messages
        while True:
            if websocket.application_state == WebSocketState.CONNECTED:
                data = await websocket.receive_text()
                message_data = json.loads(data)
               
                if "type" in message_data and message_data["type"] == "dismissal":
                    await manager_for_room.disconnect(websocket, room_name)
                    break
                else:
                    await upload_message_to_room(db,message_data)
                    # Write func. which send notify to target user
                    # await send_notify(db, message_data) 
                    #send_notification(message_data)
                    all_messages = await get_messages(db, room_name)
                    #all_messages['deviceToken']
                    last_message_for_notif = await get_messages_for_notif(db, current_user)
                    send_notification(last_message_for_notif[0], last_message_for_notif[1])
                    await manager_for_room.broadcast(all_messages)
            else:
                await manager_for_room.connect(websocket, room_name)

    except Exception as e:
        print("\n")
        print("\tcould not connect --> ", e)
        print(type(e).__name__, e.args, e.__repr__)
        print("\n")
        manager_for_room.disconnect(websocket, room_name)

@router.websocket("/chats")
async def listen_messages(db: AsyncIOMotorClient = Depends(get_database), websocket: WebSocket = WebSocket, current_user: str = Header(None)):
    """
    This function will listen users and check if they send message other users.
    """
    print()
    print("\t", current_user, " <-- connected home page")
    print()
    try:
        await manager_for_home.connect(websocket, current_user)
        initial_data = await get_messages_of_user(db, current_user)
       
        await manager_for_home.broadcast(initial_data) # should response with user chats
        
        # wait for messages
        while True:
            if websocket.application_state == WebSocketState.CONNECTED:
                data = await websocket.receive_text()
                #initial_data["chats"].append(data["chats"])
                message_data = json.loads(data)
                # Write func. which send notify to target user
                # await send_notify(db, message_data) 
                latest_data = await get_messages_of_user(db, message_data[0]['target_user']) #message_data[0]['target_user'])
                await manager_for_home.broadcast(latest_data)
            else:
                await manager_for_home.connect(websocket, current_user)

    except Exception as e:
        print("\n")
        print("\tcould not connect --> ", e)
        print(type(e).__name__, e.args, e.__repr__)
        print("\n")
        manager_for_home.disconnect(websocket,current_user)


@router.get("/user/chats/")
async def get_messages_user(db: AsyncIOMotorClient =  Depends(get_database), current_user: str = Header(None)):
    """This function will return current user chats with other ones."""
    
    chat_response = await get_messages_of_user(db, current_user)
    if len(chat_response["chats"]) >= 1:
        return JSONResponse(status_code=HTTP_200_OK, content = chat_response)
    else:
        return JSONResponse(status_code=HTTP_404_NOT_FOUND, content={"error":"Not found!"})

async def get_messages_of_user(db: AsyncIOMotorClient, current_user: str =None):
    """This function will return current user chats with other ones."""
    chat_response = { "chats": [] }

    try:
        get_username =  await db["chat-app"]["rooms"].aggregate( [{'$match':{'created_by':{ "$regex":f'{current_user}'}}}] ).to_list(length=None)
        if get_username:
            for i in get_username:
                to_response = {}
                target_user = await db["chat-app"]['users'].find_one( { 'username' :  i['target_user'] } )
        
                to_response["recvUsername"] = i["target_user"]
                to_response['recvUsername1'] = i['messages'][-1]['target_user']
                to_response["lastMessage"] = i["messages"][-1]["data"]
                to_response["lastMessageDate"] = i["messages"][-1]["date_sended"]
                to_response["msg_saw_by_tusr"] = i["messages"][-1]["msg_saw_by_tusr"]
                to_response["currentUser"] = current_user
                to_response["profilePic"] = target_user["image"]

                chat_response["chats"].append(to_response)

            return  jsonable_encoder(chat_response)

        else:
            get_username = await db["chat-app"]["rooms"].aggregate( [{'$match':{'target_user':{ "$regex":f'{current_user}'}}}] ).to_list(length=None)
            for i in get_username:
                to_response = {}
                target_user = await db["chat-app"]["users"].find_one( { 'username' :  i['created_by'] } )

                to_response["recvUsername"] = i["created_by"] # target_user 
                to_response['recvUsername1'] = i['messages'][-1]['target_user'] # last message target user
                to_response["lastMessage"] = i["messages"][-1]["data"] # last message
                to_response["lastMessageDate"] = i["messages"][-1]["date_sended"]
                to_response["msg_saw_by_tusr"] = i["messages"][-1]["msg_saw_by_tusr"]
                to_response["currentUser"] = current_user
                to_response["profilePic"] = target_user["image"]

                chat_response["chats"].append(to_response)

            return jsonable_encoder(chat_response)

    except Exception as e:
        print(e)
        return chat_response

async def get_messages_for_notif(db: AsyncIOMotorClient, current_user: str =None):
    """This function will return current user chats with other ones."""
    chat_response = { "chats": [] }

    try:
        get_username =  await db["chat-app"]["rooms"].find_one( {'created_by':f'{current_user}'} )
        if get_username:
            
            to_response = {}
            target_user = await db["chat-app"]['users'].find_one( { 'username' :  get_username['target_user'] } )
            deviceToken = target_user['deviceToken']
            to_response["recvUsername"] = get_username["target_user"]
            to_response['recvUsername1'] = get_username['messages'][-1]['target_user']
            to_response["lastMessage"] = get_username["messages"][-1]["data"]
            to_response["lastMessageDate"] = get_username["messages"][-1]["date_sended"]
            to_response["msg_saw_by_tusr"] = get_username["messages"][-1]["msg_saw_by_tusr"]
            to_response["currentUser"] = current_user
            to_response["profilePic"] = target_user["image"]

            chat_response["chats"].append(to_response)

            return ( jsonable_encoder(chat_response) , deviceToken )
            #return  jsonable_encoder(chat_response)

        else:
            get_username = await db["chat-app"]["rooms"].find_one( {'target_user': f'{current_user}'} )
            
            to_response = {}
            target_user = await db["chat-app"]["users"].find_one( { 'username' :  get_username['created_by'] } )
            deviceToken = target_user['deviceToken']
            to_response["recvUsername"] = get_username["created_by"] # target_user 
            to_response['recvUsername1'] = get_username['messages'][-1]['target_user'] # last message target user
            to_response["lastMessage"] = get_username["messages"][-1]["data"] # last message
            to_response["lastMessageDate"] = get_username["messages"][-1]["date_sended"]
            to_response["msg_saw_by_tusr"] = get_username["messages"][-1]["msg_saw_by_tusr"]
            to_response["currentUser"] = current_user
            to_response["profilePic"] = target_user["image"]

            chat_response["chats"].append(to_response)

            return ( jsonable_encoder(chat_response) , deviceToken )

    except Exception as e:
        print(e)
        return chat_response