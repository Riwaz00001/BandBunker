from src.utils.db import Base
from sqlalchemy import Column,Integer, String

class owners(Base):
    __tablename__="owners"
    owner_id=Column(Integer,primary_key=True)
    studio=Column(String,nullable=False)
    email=Column(String,nullable=False)
    number=Column(Integer,nullable=False)
    location=Column(String,nullable=False)
    room_type=Column(String,nullable=False)
    password=Column(String,nullable=False)