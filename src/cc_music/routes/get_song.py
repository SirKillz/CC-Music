from fastapi import APIRouter, Response
from fastapi.responses import JSONResponse

from cc_music.database.query_servicer import QueryServicer
from cc_music.helpers import read_dfpwm_file

get_song_router = APIRouter(prefix="/v1")
@get_song_router.get("/song")
async def get_library(video_id: str):
    query_service = QueryServicer()
    video = query_service.get_video_by_video_id(video_id)

    dfpwm_audio = read_dfpwm_file(video.file_path)
    return Response(content=dfpwm_audio.getvalue(), media_type="audio/dfpwm")