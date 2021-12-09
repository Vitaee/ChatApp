import shutil, os 
from fastapi import APIRouter, Body, Depends, UploadFile, File
from starlette.exceptions import HTTPException
from starlette.responses import JSONResponse, Response
from starlette.status import HTTP_200_OK, HTTP_400_BAD_REQUEST
from pydantic import EmailStr
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.encoders import jsonable_encoder
from db.mongosdb import AsyncIOMotorClient, get_database
from core.jwt import create_access_token, get_current_user_authorizer
from crud.user import create_user, check_free_email, get_user
from models.user import User, UserBase, UserInCreate, UserInResponse
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

    user = UserInCreate(password = password, username = username, email= email, image=f"localhost:8080/static/images/{name_of_file}.png")

    dbuser = await create_user(db, user)

    token = create_access_token(data = {"username" : dbuser.username} )

    return JSONResponse(status_code = HTTP_200_OK, content = jsonable_encoder({"token":token}) )


@router.post("/user/login", response_model=TokenResponse, tags=["Authentication"], name="Email / username login")
async def login(user: OAuth2PasswordRequestForm = Depends(), db: AsyncIOMotorClient = Depends(get_database) ):
    if '@' in user.username:
        field = "email"
    else: 
        field = "username"

    
    dbuser = await get_user(db, field = field, value = user.username )

    if not dbuser or not dbuser.check_password(user.password):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Wrong username / password!")
    
    token = create_access_token(data = {"username" : dbuser.username})
    return TokenResponse(access_token = token)

@router.get("/user", response_model=UserBase, tags=["Authentication"], name="Get current user")
async def retrieve_user(user: User = Depends(get_current_user_authorizer())):
    return JSONResponse(status_code=HTTP_200_OK, content=jsonable_encoder(user) )