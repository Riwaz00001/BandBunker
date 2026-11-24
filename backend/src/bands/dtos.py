from pydantic import BaseModel
from datetime import datetime

class band_response(BaseModel):
    band_id:int
    band_name:str
    description:str|None
    genre:str
    profile_pic_url:str|None
    owner_id:int

class band_member_response(BaseModel):
    musician_id: int
    name: str
    role: str
    profile_pic_url: str | None

class band_members_response(BaseModel):
    members: list[band_member_response]

class invite_response(BaseModel):
    invite_id: int
    band_id: int
    band_name: str
    profile_pic_url: str | None
    musician_id: int
    created_at: datetime

