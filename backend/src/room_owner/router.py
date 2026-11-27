from fastapi import APIRouter,Depends, status, HTTPException
from sqlalchemy.orm import Session
from src.room_owner.dtos import registration_info,registration_response,login_info,RoomCreateRequest,RoomResponse,BookingCreateRequest,BookingResponse
from src.utils.db import get_db
from src.room_owner.controller import register_owner,login_owner,create_room,list_rooms,list_owner_rooms,create_booking,list_owner_bookings,update_booking_status
from src.utils.auth import authenticated_owner,authenticated_musician
from src.room_owner.models import Room,Booking
from src.bands.models import bands
from src.room_owner.models import owners

owners_router=APIRouter(prefix="/owner")
rooms_router=APIRouter(prefix="/rooms")
bookings_router=APIRouter(prefix="/bookings")

@owners_router.post("/register",response_model=registration_response,status_code=status.HTTP_201_CREATED)
def register(user:registration_info,db:Session=Depends(get_db)):
    return register_owner(user,db)

@owners_router.post("/login",status_code=status.HTTP_200_OK)
def login(user:login_info,db:Session=Depends(get_db)):
    return login_owner(user,db)

@owners_router.post("/rooms",response_model=RoomResponse,status_code=status.HTTP_201_CREATED)
def create_room_endpoint(payload:RoomCreateRequest,owner=Depends(authenticated_owner),db:Session=Depends(get_db)):
    room=create_room(owner,payload,db)
    return RoomResponse(room_id=room.room_id,owner_id=room.owner_id,name=room.name,location=room.location,room_type=room.room_type,price=room.price,time_slots=room.time_slots)

@owners_router.get("/rooms",response_model=list[RoomResponse])
def my_rooms(owner=Depends(authenticated_owner),db:Session=Depends(get_db)):
    rooms=list_owner_rooms(owner,db)
    return [RoomResponse(room_id=r.room_id,owner_id=r.owner_id,name=r.name,location=r.location,room_type=r.room_type,price=r.price,time_slots=r.time_slots) for r in rooms]

@owners_router.get("/bookings",response_model=list[BookingResponse])
def owner_bookings(owner=Depends(authenticated_owner),db:Session=Depends(get_db)):
    bookings=list_owner_bookings(owner,db)
    out=[]
    for b in bookings:
        room=db.query(Room).filter(Room.room_id==b.room_id).first()
        band=db.query(bands).filter(bands.band_id==b.band_id).first()
        out.append(BookingResponse(booking_id=b.booking_id,room_id=b.room_id,room_name=room.name if room else "",band_id=b.band_id,band_name=band.band_name if band else "",date=b.date,time_slot=b.time_slot,status=b.status))
    return out

@owners_router.patch("/bookings/{booking_id}",response_model=BookingResponse)
def update_booking(booking_id:int,status:str,owner=Depends(authenticated_owner),db:Session=Depends(get_db)):
    booking=update_booking_status(owner,booking_id,status,db)
    room=db.query(Room).filter(Room.room_id==booking.room_id).first()
    band=db.query(bands).filter(bands.band_id==booking.band_id).first()
    return BookingResponse(booking_id=booking.booking_id,room_id=booking.room_id,room_name=room.name if room else "",band_id=booking.band_id,band_name=band.band_name if band else "",date=booking.date,time_slot=booking.time_slot,status=booking.status)

@rooms_router.get("",response_model=list[RoomResponse])
def all_rooms(db:Session=Depends(get_db)):
    rooms=list_rooms(db)
    return [RoomResponse(room_id=r.room_id,owner_id=r.owner_id,name=r.name,location=r.location,room_type=r.room_type,price=r.price,time_slots=r.time_slots) for r in rooms]

@bookings_router.post("",response_model=BookingResponse,status_code=status.HTTP_201_CREATED)
def create_booking_endpoint(payload:BookingCreateRequest,musician=Depends(authenticated_musician),db:Session=Depends(get_db)):
    booking,room,band=create_booking(musician,payload,db)
    return BookingResponse(booking_id=booking.booking_id,room_id=booking.room_id,room_name=room.name,band_id=booking.band_id,band_name=band.band_name,date=booking.date,time_slot=booking.time_slot,status=booking.status)
