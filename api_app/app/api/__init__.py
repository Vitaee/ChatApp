from fastapi import APIRouter

from api.authentication import router as auth_router


router = APIRouter()

router.include_router(auth_router)