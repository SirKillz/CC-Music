from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class Videos(Base):
    __tablename__ = "videos"

    id = Column(Integer, primary_key=True, autoincrement=True)
    video_id = Column(String(255), nullable=False, unique=True)
    video_title = Column(String(255), nullable=False)
    file_path = Column(String(255), nullable=False)

    def __repr__(self):
        return f"<VideosTable(id={self.id}, video_id={self.video_id}, title={self.video_title}, file_path={self.file_path})>"