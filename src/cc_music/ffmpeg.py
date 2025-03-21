import subprocess
from io import BytesIO

def convert_to_dfpwm(input_audio: BytesIO):
    input_audio.seek(0)

    ffmpeg_proc = subprocess.Popen(
        [
            'ffmpeg',
            '-i', 'pipe:',
            '-ar', '48000',  # set sample rate to 48 kHz
            '-ac', '1',      # force mono audio
            '-f', 'dfpwm',
            'pipe:'
        ],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )

    output_audio, error = ffmpeg_proc.communicate(input=input_audio.read())

    if ffmpeg_proc.returncode != 0:
        raise RuntimeError(f"FFmpeg conversion failed: {error.decode()}")

    return BytesIO(output_audio)

