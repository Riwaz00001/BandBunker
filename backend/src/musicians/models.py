from src.utils.db import Base
from sqlalchemy import Column,Integer, String

class musicians(Base):
    __tablename__="musicians"
    musician_id=Column(Integer,primary_key=True)
    name=Column(String,nullable=False)
    email=Column(String,nullable=False)
    password=Column(String,nullable=False)
    role=Column(String,nullable=False)