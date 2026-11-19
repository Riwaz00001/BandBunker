from pydantic import BaseModel

class registration_info(BaseModel):
    name:str
    studio:str
    email:str
    number:str
    location:str
    room_type:str
    password:str

class registration_response(BaseModel):
    email:str
    number:str

class login_info(BaseModel):
    email:str
    password:str