from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.room_owner.dtos import registration_info,login_info,RoomCreateRequest,BookingCreateRequest
from src.room_owner.models import owners,Room,Booking
from src.bands.models import bands
from src.musicians.models import musicians
from pwdlib import PasswordHash
import jwt
from datetime import datetime,timedelta,date
from src.utils.settings import settings
password_hash=PasswordHash.recommended()
def get_hashed_password(password):
    return password_hash.hash(password)
def verify_password(password,hashed_password):
    return password_hash.verify(password,hashed_password)

def register_owner(user:registration_info,db:Session=Depends(get_db)):
    existing_user=db.query(owners).filter(user.email==owners.email).first()
    if existing_user:
        raise HTTPException(status_code=400,detail="Email already in use!")
    password=get_hashed_password(user.password)
    owner=owners(name=user.name,studio=user.studio,email=user.email,number=user.number,location=user.location,room_type=user.room_type,password=password)
    db.add(owner)
    db.commit()
    db.refresh(owner)
    return owner

def login_owner(user:login_info,db:Session=Depends(get_db)):
    correct_user=db.query(owners).filter(user.email==owners.email).first()
    if not correct_user or not verify_password(user.password,correct_user.password):
            raise HTTPException(status_code=401,detail="Incorrect password or username")
    exp_time=datetime.now()+timedelta(days=settings.EXP_TIME)
    token=jwt.encode({"user_id":correct_user.owner_id,"exp_time":exp_time.timestamp()},settings.SECRET_KEY,settings.ALGORITHM)
    return {"token":token}

def create_room(owner:owners,payload:RoomCreateRequest,db:Session):
    try:
        price=float(payload.price)
    except ValueError:
        raise HTTPException(status_code=400,detail="Please enter a valid hourly price.")
    if price<=0:
        raise HTTPException(status_code=400,detail="Please enter a valid hourly price.")
    if not payload.selected_slots:
        raise HTTPException(status_code=400,detail="Please select at least one available time slot.")
    allowed={'Jamming Studio','Rehearsal Room','Recording Studio'}
    if payload.room_type not in allowed:
        raise HTTPException(status_code=400,detail="Invalid room type.")
    existing=db.query(Room).filter(Room.owner_id==owner.owner_id,Room.room_type==payload.room_type).first()
    if existing:
        raise HTTPException(status_code=400,detail="You already created a room of this type.")
    count=db.query(Room).filter(Room.owner_id==owner.owner_id).count()
    if count>=3:
        raise HTTPException(status_code=400,detail="Maximum 3 rooms allowed.")
    room=Room(owner_id=owner.owner_id,name=owner.studio,location=owner.location,room_type=payload.room_type,price=payload.price,time_slots=payload.selected_slots)
    db.add(room)
    db.commit()
    db.refresh(room)
    return room

def list_rooms(db:Session):
    return db.query(Room).all()

def list_owner_rooms(owner:owners,db:Session):
    return db.query(Room).filter(Room.owner_id==owner.owner_id).all()

def create_booking(musician:musicians,payload:BookingCreateRequest,db:Session):
    room=db.query(Room).filter(Room.room_id==payload.room_id).first()
    if not room:
        raise HTTPException(status_code=404,detail="Room not found.")
    if payload.time_slot not in (room.time_slots or []):
        raise HTTPException(status_code=400,detail="Invalid time slot for this room.")
    band=db.query(bands).filter(bands.band_id==payload.band_id).first()
    if not band or band.owner_id!=musician.musician_id:
        raise HTTPException(status_code=403,detail="Only band owners can book rooms.")
    collision=db.query(Booking).filter(Booking.room_id==payload.room_id,Booking.date==payload.date,Booking.time_slot==payload.time_slot,Booking.status!="Rejected").first()
    if collision:
        raise HTTPException(status_code=409,detail="This time slot is already booked. Please choose another.")
    booking=Booking(room_id=room.room_id,band_id=band.band_id,musician_id=musician.musician_id,date=payload.date,time_slot=payload.time_slot,status="Pending")
    db.add(booking)
    db.commit()
    db.refresh(booking)
    return booking,room,band

def list_owner_bookings(owner:owners,db:Session):
    rooms=db.query(Room).filter(Room.owner_id==owner.owner_id).all()
    room_ids=[r.room_id for r in rooms]
    if not room_ids:
        return []
    return db.query(Booking).filter(Booking.room_id.in_(room_ids)).all()

def list_musician_bookings(musician:musicians,db:Session):
    return db.query(Booking).filter(Booking.musician_id==musician.musician_id).all()
    rooms=db.query(Room).filter(Room.owner_id==owner.owner_id).all()
    room_ids=[r.room_id for r in rooms]
    if not room_ids:
        return []
    return db.query(Booking).filter(Booking.room_id.in_(room_ids)).all()

def update_booking_status(owner:owners,booking_id:int,status:str,db:Session):
    booking=db.query(Booking).filter(Booking.booking_id==booking_id).first()
    if not booking:
        raise HTTPException(status_code=404,detail="Booking not found.")
    room=db.query(Room).filter(Room.room_id==booking.room_id).first()
    if not room or room.owner_id!=owner.owner_id:
        raise HTTPException(status_code=403,detail="Not authorized.")
    if status not in ("Accepted","Rejected"):
        raise HTTPException(status_code=400,detail="Invalid status.")
    booking.status=status
    db.commit()
    db.refresh(booking)
    return booking
