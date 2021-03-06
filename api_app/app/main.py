from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from starlette.exceptions import HTTPException
from starlette.middleware.cors import CORSMiddleware
import uvicorn
from fastapi_contrib.tracing.utils import setup_opentracing
from fastapi_contrib.tracing.middlewares import OpentracingMiddleware
from fastapi.staticfiles import StaticFiles

from core.errors import http_error_handler, http422_error_handler
from db.mongodb_utils import connect_to_mongodb, close_mongo_connection
from core.config import ALLOWED_HOSTS, API_PREFIX, DEBUG, PROJECT_NAME, VERSION, HOST, PORT
from api import router as api_router



app = FastAPI(title=PROJECT_NAME, debug=DEBUG, version=VERSION)
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_HOSTS or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.add_event_handler("startup", connect_to_mongodb)
app.add_event_handler("shutdown", close_mongo_connection)
# set opentracing
@app.on_event('startup')
async def startup():
    setup_opentracing(app)
    app.add_middleware(OpentracingMiddleware)

app.add_exception_handler(HTTPException, http_error_handler)
app.add_exception_handler(RequestValidationError, http422_error_handler)

app.include_router(api_router, prefix=API_PREFIX)

app.mount("/static", StaticFiles(directory="static"), name="static")


if __name__ == '__main__':
    uvicorn.run(
        "main:app",
        host=HOST,
        port=PORT,
        reload=True,
        workers=1
    )
