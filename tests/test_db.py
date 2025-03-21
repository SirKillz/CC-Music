import os

from dotenv import load_dotenv
load_dotenv(".env")
os.environ['ENV'] = 'test'

from cc_music.database.query_servicer import QueryServicer


def test_get_video_by_video_id():
    query_servicer = QueryServicer()
    video = query_servicer.get_video_by_video_id("fart")
    
def test_create_video():
    query_servicer = QueryServicer()
    video = query_servicer.create_video("asdasdsa", "Old Thing Back", "/data/files/test456.dfpw")
    print(video)

test_create_video()