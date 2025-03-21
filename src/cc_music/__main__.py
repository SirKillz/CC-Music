from io import BytesIO

from fastapi import FastAPI, Response
import yt_dlp
import httpx

from cc_music.database.query_servicer import QueryServicer
from cc_music.helpers import extract_video_id, read_dfpwm_file, write_dfpwm_file, write_mp3_file
from cc_music.ffmpeg import convert_to_dfpwm


app = FastAPI()


@app.get("/get-music")
async def get_music(video_url: str):

    extracted_video_id = extract_video_id(video_url)

    query_service = QueryServicer()
    video = query_service.get_video_by_video_id(extracted_video_id)

    if video:
        print("Video already exists in database. Reading from file...", flush=True)
        dfpwm_audio = read_dfpwm_file(video.file_path)
        return Response(content=dfpwm_audio.getvalue(), media_type="audio/dfpwm")

    else:
        print("Starting YouTube processing...", flush=True)

        # Use yt-dlp to get direct audio URL in bestaudio format (usually MP3 or similar)
        ydl_opts = {"format": "bestaudio/best", "quiet": True}
        with yt_dlp.YoutubeDL(ydl_opts) as ydl:
            info = ydl.extract_info(video_url, download=False)
            audio_url = info["url"]

        print("Downloading and streaming audio...", flush=True)
        # Download audio with httpx
        with httpx.stream("GET", audio_url) as response:
            response.raise_for_status()
            buffer = BytesIO()
            for chunk in response.iter_bytes(chunk_size=8192):  # 8KB per chunk
                buffer.write(chunk)

        print("Download complete.", flush=True)

        # Save the MP3 file to the volume for testing purposes
        buffer.seek(0)
        mp3_file_path = f"/data/files/{extracted_video_id}.mp3"
        write_mp3_file(mp3_file_path, buffer)
        print("MP3 file written to storage.", flush=True)

        # Reset buffer position for conversion
        buffer.seek(0)
        print("Starting conversion to DFPWM...", flush=True)
        dfpwm_audio = convert_to_dfpwm(buffer)
        print("Conversion complete.", flush=True)

        # Add video to database with a .dfpw extension (assumed to be a typo for .dfpwm)
        video_id = extracted_video_id
        video_title = info["title"]
        file_path = f"/data/files/{video_id}.dfpwm"
        query_service.create_video(video_id, video_title, file_path)
        write_dfpwm_file(file_path, dfpwm_audio)
        print("Video added to database. Returning response...", flush=True)

        return Response(content=dfpwm_audio.getvalue(), media_type="audio/dfpwm")

