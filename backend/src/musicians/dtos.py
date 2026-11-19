from pydantic import BaseModel

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
