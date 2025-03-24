from .db_connection import Database
from .db_model import Videos

class QueryServicer(Database):
    def __init__(self):
        super().__init__()

    def get_video_by_video_id(self, video_id):
        with self.Session() as session:
            result = session.query(Videos).filter_by(video_id=video_id).first()

            if result is not None:
                return result

            return None
        
    def create_video(self, video_id, video_title, file_path):
        with self.Session() as session:
            video = Videos(video_id=video_id, video_title=video_title, file_path=file_path)
            session.add(video)
            session.commit()

            return video
        
    def get_video_library(self, page: int = 1):
        items_per_page = 8
        offset = (page - 1) * items_per_page
        with self.Session() as session:
            result = session.query(Videos).offset(offset).limit(items_per_page).all()
            return result