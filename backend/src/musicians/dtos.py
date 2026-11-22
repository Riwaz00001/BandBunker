from pydantic import BaseModel
from datetime import datetime
class registration_info(BaseModel):
    name:str
    email:str
    password:str
    role:str

class registration_response(BaseModel):
    email:str
    role:str

class login_info(BaseModel):
    email:str
    password:str

class post_response(BaseModel):
    musician_id:int
    musician_name:str
    profile_pic_url:str|None
    caption:str
    media_type:str
    media_url:str
    created_at:datetime

class profile_response(BaseModel):
    name:str
    email:str
    role:str
    bio:str|None
    profile_pic_url:str |None


class profile_response(BaseModel):
    name:str
    email:str
    role:str
    bio:str|None
    profile_pic_url:str |None

class public_profile_response(BaseModel):
    name: str
    role: str
    bio: str | None
    profile_pic_url: str | None