from motor.motor_asyncio import AsyncIOMotorClient

from core.config import MONGODB_URL, MAX_CONNECTIONS_COUNT, MIN_CONNECTIONS_COUNT
from db.mongosdb import db


async def connect_to_mongodb() -> None:
    db.client = AsyncIOMotorClient(str(MONGODB_URL),
                                   maxPoolSize=MAX_CONNECTIONS_COUNT,
                                   minPoolSize=MIN_CONNECTIONS_COUNT)


async def close_mongo_connection():
    db.client.close()