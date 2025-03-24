from io import BytesIO

def extract_video_id(url: str) -> str:
    return url.split("=")[1]

def clean_video_title(video_title: str) -> str:
    return video_title.replace('"', "")

def read_dfpwm_file(file_path: str) -> BytesIO:
    with open(file_path, "rb") as file:
        return BytesIO(file.read())

def write_dfpwm_file(file_path: str, dfpwm_audio: BytesIO) -> None:
    with open(file_path, "wb") as file:
        file.write(dfpwm_audio.getvalue())

def write_mp3_file(file_path: str, mp3_audio: BytesIO) -> None:
    with open(file_path, "wb") as file:
        file.write(mp3_audio.getvalue())