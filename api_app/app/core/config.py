import sys
from typing import List
from databases import DatabaseURL
from starlette.config import Config
from starlette.datastructures import CommaSeparatedStrings, Secret

API_PREFIX = "/api"
JWT_TOKEN_PREFIX = "Bearer"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7
VERSION = "0.1.0"

config = Config(".env")

DEBUG: bool = config("DEBUG", cast=bool, default=True)
HOST: str = config("HOST", default='0.0.0.0')
PORT: int = config("PORT", cast=int, default=8080)
# mongo
MONGODB_URL: DatabaseURL = config("MONGODB_URL", cast=DatabaseURL, default='mongodb+srv://cykoUser:zS73IOcwf8jjyG40@cluster0.dblj8.mongodb.net/?retryWrites=true&w=majority')#'mongodb://172.17.0.2:27017')
MAX_CONNECTIONS_COUNT: int = config("MAX_CONNECTIONS_COUNT", cast=int, default=10)
MIN_CONNECTIONS_COUNT: int = config("MIN_CONNECTIONS_COUNT", cast=int, default=10)

SECRET_KEY: Secret = config("SECRET_KEY", cast=Secret, default='secret_key')

PROJECT_NAME: str = config("PROJECT_NAME", default="FastAPI JWT & File")
ALLOWED_HOSTS: List[str] = config(
    "ALLOWED_HOSTS", cast=CommaSeparatedStrings, default="*",
)

database_name: str = config('DATABASE_NAME', default='chat-app')
user_collection_name = 'users'
fastapi_url = 'localhost'