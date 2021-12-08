import shutil , os , base64
from fastapi import APIRouter, Body, Depends, UploadFile, File
from starlette.exceptions import HTTPException
from starlette.responses import Response
from starlette.status import HTTP_400_BAD_REQUEST
from pydantic import EmailStr
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import Response

from db.mongosdb import AsyncIOMotorClient, get_database
from core.jwt import create_access_token, get_current_user_authorizer
from crud.user import create_user, check_free_email, get_user
from models.user import User, UserInCreate, UserInResponse
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

    user = UserInCreate(password = password, username = username, email= email, image=f"localhost:8080/static/images/{name_of_file}")

    dbuser = await create_user(db, user)

    token = create_access_token(data = {"id" : dbuser._id} )

    return UserInResponse(user=User(**dbuser.dict(), token=token))


@router.post("/user/login", response_model=TokenResponse, tags=["Authentication"], name="Email / username login")
async def login(user: OAuth2PasswordRequestForm = Depends(), db: AsyncIOMotorClient = Depends(get_database) ):
    if '@' in user.username:
        field = "email"
    else: 
        field = "username"

    
    dbuser = await get_user(db, field = field, value = user.username )

    if not dbuser or not dbuser.check_password(user.password):
        raise HTTPException(status_code=HTTP_400_BAD_REQUEST, detail="Wrong username / password!")
    
    print(dbuser)
    token = create_access_token(data = {"id" : dbuser.id}) 

    return TokenResponse(access_token = token)

@router.get("/user", response_model=UserInResponse, tags=["Authentication"], name="Get current user")
async def retrieve_user(user: User = Depends(get_current_user_authorizer())):
    print(user)
    return UserInResponse(user = user)