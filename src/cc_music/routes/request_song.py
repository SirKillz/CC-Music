from io import BytesIO

from fastapi import APIRouter, BackgroundTasks
from fastapi.responses import JSONResponse

import yt_dlp
import httpx

from cc_music.database.query_servicer import QueryServicer
from cc_music.helpers import extract_video_id, write_dfpwm_file, write_mp3_file
from cc_music.ffmpeg import convert_to_dfpwm

query_service = QueryServicer()

def process_song_in_background(video_url: str, video_id: str):
    # Use yt-dlp to get direct audio URL in bestaudio format (usually MP3 or similar)
    ydl_opts = {"format": "bestaudio/best", "quiet": True}
    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        info = ydl.extract_info(video_url, download=False)
        audio_url = info["url"]

    print("Downloading and streaming audio...", flush=True)
    # Download audio with httpx
    with httpx.stream("GET", audio_url, follow_redirects=True) as response:
        response.raise_for_status()
        buffer = BytesIO()
        for chunk in response.iter_bytes(chunk_size=8192):  # 8KB per chunk
            buffer.write(chunk)

    print("Download complete.", flush=True)

    # Save the MP3 file to the volume for testing purposes
    buffer.seek(0)
    mp3_file_path = f"/data/files/{video_id}.mp3"
    write_mp3_file(mp3_file_path, buffer)
    print("MP3 file written to storage.", flush=True)

    # Reset buffer position for conversion
    buffer.seek(0)
    print("Starting conversion to DFPWM...", flush=True)
    dfpwm_audio = convert_to_dfpwm(buffer)
    print("Conversion complete.", flush=True)

    # Add video to database with the correct file extension (.dfpwm)
    video_title = info["title"]
    file_path = f"/data/files/{video_id}.dfpwm"
    query_service.create_video(video_id, video_title, file_path)
    write_dfpwm_file(file_path, dfpwm_audio)
    print("Video added to database.", flush=True)

request_song_router = APIRouter(prefix="/v1")

@request_song_router.post("/request/song")
async def get_music(video_url: str, background_tasks: BackgroundTasks):
    extracted_video_id = extract_video_id(video_url)

    video = query_service.get_video_by_video_id(extracted_video_id)
    if video:
        return JSONResponse(
            content={
                "message": "This video already exists in the database, please select from the library."
            }
        )
    else:
        print("Starting YouTube processing...", flush=True)
        background_tasks.add_task(process_song_in_background, video_url, extracted_video_id)
        return JSONResponse(
            content={"message": "Processing video in the background. Check back in 2-3 minutes."}
        )
