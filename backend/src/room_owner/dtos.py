from pydantic import BaseModel
from typing import List, Optional
from datetime import date

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

class RoomCreateRequest(BaseModel):
    price: str
    selected_slots: List[str]

class RoomResponse(BaseModel):
    room_id: int
    owner_id: int
    name: str
    location: str
    room_type: str
    price: str
    time_slots: List[str]

class BookingCreateRequest(BaseModel):
    room_id: int
    band_id: int
    date: date
    time_slot: str

class BookingResponse(BaseModel):
    booking_id: int
    room_id: int
    room_name: str
    band_id: int
    band_name: str
    date: date
    time_slot: str
    status: str
