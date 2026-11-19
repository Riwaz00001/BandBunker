from pydantic import BaseModel
import datetime
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
    musician_name:str
    caption:str
    media_type:str
    media_url:str
    created_at:datetime