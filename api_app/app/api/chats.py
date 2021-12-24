from fastapi import APIRouter
from starlette.websockets import WebSocket, WebSocketDisconnect
from crud.chat import manager
router = APIRouter()

@router.websocket("/chat/{room_name}/{current_username}")
async def websocket_endpoint(websocket: WebSocket, room_name, current_username):
    try:
        pass

    except: pass





"""
if current_username: 
    await manager.connect(websocket, current_username)
    response = {
        "sender": current_username,
        "message": "got connected"
    }
    await manager.broadcast(response)
    try:
        while True:
            data = await websocket.receive_json()
            await manager.broadcast(data)
    except WebSocketDisconnect:
        manager.disconnect(websocket, current_username)
        response['message'] = "left"
        await manager.broadcast(response)
else:
    print("No sender")
"""