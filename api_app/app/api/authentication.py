import shutil, os 
from fastapi import APIRouter, Body, Depends, UploadFile, File
from fastapi.param_functions import Header
from starlette.exceptions import HTTPException
from starlette.responses import JSONResponse
from starlette.status import HTTP_200_OK, HTTP_400_BAD_REQUEST, HTTP_404_NOT_FOUND
from pydantic import EmailStr
from fastapi.encoders import jsonable_encoder
from core.config import fastapi_url
from core.auth_bearer import JwtBearer
from db.mongosdb import AsyncIOMotorClient, get_database
from core.jwt import create_access_token
from crud.user import create_user, check_free_email, get_filtered_users, get_messages, get_user
from models.user import User, UserBase, UserInCreate, UserInRequest, UserInResponse, ListUser
from models.token import TokenResponse
router = APIRouter()
@router.post("/user/register", response_model=UserInResponse, tags=["Authentication"], name="Registration")
async def register(db:AsyncIOMotorClient = Depends(get_database), email: EmailStr = Body(...), password: str = Body(...), username: str = Body(...), file: UploadFile = File(...)):
    
    await check_free_email(db, email=email)

    if not os.path.isdir('./static/images'):
        os.umask(0)
        os.makedirs('./static/images', mode=0o777)
    

    name_of_file = file.filename.replace(" ", "").split(".")[0]

    with open(f"./static/images/{name_of_file}.png", "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    user = UserInCreate(password = password, username = username, email= email, image=f"{fastapi_url}:8080/static/images/{name_of_file}.png")

    dbuser = await create_user(db, user)

    token = create_access_token(data = {"username" : dbuser.username} )

    return JSONResponse(status_code = HTTP_200_OK, content = jsonable_encoder({"token":token}) )


@router.post("/user/login", response_model=TokenResponse, tags=["Authentication"], name="Email / username login")
async def login(data: UserInRequest = Body(...), db: AsyncIOMotorClient = Depends(get_database) ):
    print(data)
    if '@' in data.username:
        field = "email"
    
    else: 
        field = "username"
    
    dbuser = await get_user(db, field = field, value = data.username )
    if not dbuser or not dbuser.check_password(data.password):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Wrong username / password!")
    
    token = create_access_token(data = {"username" : dbuser.username})
    return JSONResponse(status_code=HTTP_200_OK, content= jsonable_encoder( { "token":token} ))

@router.get("/user", response_model=UserBase, tags=["Authentication"], dependencies=[Depends(JwtBearer())], name="Get current user")
async def retrieve_user(db: AsyncIOMotorClient = Depends(get_database),current_username: User = Depends(JwtBearer())):
    current_user =  await get_user(db, field="username", value=current_username) 
    return JSONResponse(status_code=HTTP_200_OK, content=jsonable_encoder(current_user))

@router.post("/user/deviceToken", dependencies=[Depends(JwtBearer())], name="Save device token of user")
async def save_device_token(db: AsyncIOMotorClient = Depends(get_database), data = Body(...) , current_user: str = Header(None)):
    """update user's  device token."""
    await db["chat-app"]["users"].update_one( {"username": current_user}, {"$set": {"deviceToken":data['fcm_token']}} )
    return JSONResponse(status_code=HTTP_200_OK, content=[{}])

@router.post("/user/filter/{query}", name="Get all users")
async def filter_users(query: str, db:AsyncIOMotorClient=Depends(get_database), current_user: str = Header(None) ):
    finded_users = None

    if current_user:
        finded_users = await get_filtered_users(db, query )

    if finded_users:
        res = ListUser(**finded_users)
        return JSONResponse(status_code = HTTP_200_OK, content = res.dict()["result"] )
    else:
        return JSONResponse(status_code = HTTP_404_NOT_FOUND, content={"error":"User not found!"})

@router.get("/messages/{room_name}/")
async def messages(db:AsyncIOMotorClient = Depends(get_database), room_name: str = ""):
    room_messages = await get_messages(db, room_name)
    if room_messages:
        return JSONResponse(status_code=HTTP_200_OK, content=room_messages)

    return JSONResponse(status_code=HTTP_200_OK, content=[{}])