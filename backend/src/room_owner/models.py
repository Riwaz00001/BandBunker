from src.utils.db import Base
from sqlalchemy import Column, Integer, String, Float, ForeignKey, Date, DateTime, JSON
from sqlalchemy.orm import relationship
from datetime import datetime

class owners(Base):
    __tablename__="owners"
    owner_id=Column(Integer,primary_key=True)
    name=Column(String,nullable=False)
    studio=Column(String,nullable=False)
    email=Column(String,nullable=False)
    number=Column(String,nullable=False)
    location=Column(String,nullable=False)
    room_type=Column(String,nullable=False)
    password=Column(String,nullable=False)

class Room(Base):
    __tablename__="rooms"
    room_id=Column(Integer,primary_key=True)
    owner_id=Column(Integer,ForeignKey("owners.owner_id",ondelete="CASCADE"),nullable=False)
    name=Column(String,nullable=False)
    location=Column(String,nullable=False)
    room_type=Column(String,nullable=False)
    price=Column(String,nullable=False)
    time_slots=Column(JSON,nullable=False)
    created_at=Column(DateTime,default=datetime.utcnow)

class Booking(Base):
    __tablename__="bookings"
    booking_id=Column(Integer,primary_key=True)
    room_id=Column(Integer,ForeignKey("rooms.room_id",ondelete="CASCADE"),nullable=False)
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),nullable=False)
    musician_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),nullable=False)
    date=Column(Date,nullable=False)
    time_slot=Column(String,nullable=False)
    status=Column(String,nullable=False,default="Pending")
    created_at=Column(DateTime,default=datetime.utcnow)
