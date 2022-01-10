from fastapi import APIRouter

from api.authentication import router as auth_router
from api.chats import router as socket_router

router = APIRouter()

router.include_router(auth_router)
router.include_router(socket_router)