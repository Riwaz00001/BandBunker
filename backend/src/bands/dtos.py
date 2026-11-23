from pydantic import BaseModel

class band_response(BaseModel):
    band_id:int
    band_name:str
    description:str|None
    genre:str
    profile_pic_url:str|None
    owner_id:int

