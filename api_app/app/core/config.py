from email.policy import default
import sys
from typing import List
from databases import DatabaseURL
from starlette.config import Config
from starlette.datastructures import CommaSeparatedStrings, Secret

API_PREFIX = "/api"
JWT_TOKEN_PREFIX = "Bearer"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7
VERSION = "0.1.0"

config = Config("prod.env")

DEBUG: bool = config("DEBUG", cast=bool, default=True)
HOST: str = config("HOST", default='0.0.0.0')
PORT: int = config("PORT", cast=int, default=8080)

# mongo
MONGODB_URL: DatabaseURL = config("MONGODB_URL", cast=DatabaseURL, default='mongodb://185.250.192.69:27017')
MAX_CONNECTIONS_COUNT: int = config("MAX_CONNECTIONS_COUNT", cast=int, default=10)
MIN_CONNECTIONS_COUNT: int = config("MIN_CONNECTIONS_COUNT", cast=int, default=10)

SECRET_KEY: Secret = config("SECRET_KEY", cast=Secret, default='secret_key')

PROJECT_NAME: str = config("PROJECT_NAME", default="FastAPI JWT Auth. & Chat App")
ALLOWED_HOSTS: List[str] = config(
    "ALLOWED_HOSTS", cast=CommaSeparatedStrings, default="*",
)

ALLOWED_METHODS: List[str] = config('ALLOWED_METHODS', cast=CommaSeparatedStrings, default="*")

DB_NAME: str = config('DATABASE_NAME', default='chat-app')
USER_COLLECTION_NAME: str = 'users'
FASTAPI_URL: str = config('HOST', default='localhost')

NOTIF_JSON_PATH: str = config('NOTIF_JSON_PATH', cast=str, default='E:\\MainProjects\\ChatApp\\api_app\\app\\common\\pushnotif-78183-firebase-adminsdk-dwgqs-50f4ba7d6f.json')

