import shutil , os , base64
from fastapi import APIRouter, Body, Depends, UploadFile, File
from starlette.exceptions import HTTPException
from starlette.responses import Response
from starlette.status import HTTP_400_BAD_REQUEST
from pydantic import EmailStr
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.responses import Response

from db.mongosdb import AsyncIOMotorClient, get_database
from core.jwt import create_access_token
from crud.user import create_user, check_free_email, get_user
from models.user import User, UserBase, UserInCreate, UserInResponse
from models.token import TokenResponse

router = APIRouter()

@router.post("/users/register", response_model=UserInResponse, tags=["Authentication"], name="Registration")
async def register(db:AsyncIOMotorClient = Depends(get_database), email: EmailStr = Body(...), password: str = Body(...), username: str = Body(...), file: UploadFile = File(...)):
    await check_free_email(db, email=email)

    user_image = await file.read()
    base64bytes = base64.b64encode(user_image)

    if not os.path.isdir('../static/images'):
        os.umask(0)
        os.makedirs('../static/images', mode=0o777)
    

    name_of_file = file.filename.replace(" ", "").split(".")[0]

    with open(f"../static/images/{name_of_file}.png", "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    user = UserInCreate(password = password, username = username, email= email, image=base64bytes) 
    # user.image.decode('utf-8') but to much space in DB.

    dbuser = await create_user(db, user)

    token = create_access_token(data = {"id" : dbuser._id} )

    return UserInResponse(user=User(**dbuser.dict(), token=token))