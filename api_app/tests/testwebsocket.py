import asyncio
import websockets
import time
def test_url(url):
    async def inner():
        async with websockets.connect(url,ping_interval = None) as websocket:
            while True:
                result = await websocket.recv()
                print(result)
                await asyncio.sleep(0.5)

                await websocket.send('[{ "type":"entrance", "data":"hello!", "room_name":"room1", "user":"can" }]')
                response = await websocket.recv()
                print(response)
                
                if response:
                    websocket.close()
                    break
    
    return asyncio.get_event_loop().run_until_complete(inner())

test_url("ws://127.0.0.1:8080/api/chat/room1/can")