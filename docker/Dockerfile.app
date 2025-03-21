FROM python:3.12

# Install FFmpeg from apt
RUN apt-get update && apt-get install -y ffmpeg && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY src/cc_music/ /app/cc_music/

CMD ["uvicorn", "cc_music.__main__:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]