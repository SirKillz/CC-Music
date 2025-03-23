from fastapi import APIRouter
from fastapi.responses import JSONResponse

from cc_music.database.query_servicer import QueryServicer

get_library_router = APIRouter(prefix="/v1")
@get_library_router.get("/library")
async def get_library(page: int = 1):
    query_service = QueryServicer()
    results = query_service.get_video_library(page)

    videos = {}
    for video in results:
        videos[video.video_title] = {
            "video_id": video.video_id,
            "file_path": video.file_path
        }

    return JSONResponse(content={"videos": videos})