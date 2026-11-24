from sqlalchemy.orm import Session
from src.utils.db import Base
from sqlalchemy import ForeignKey, Column, Integer, String,UniqueConstraint
class bands(Base):
    __tablename__="bands"
    band_id=Column(Integer,primary_key=True)
    band_name=Column(String,nullable=False)
    owner_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),nullable=False,index=True)
    description=Column(String,nullable=True)
    genre=Column(String,nullable=False)
    profile_pic_path=Column(String,nullable=True)

class band_members(Base):
    __tablename__="band_members"
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),primary_key=True)
    musician_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),primary_key=True)
    role=Column(String,nullable=False,default="member")

class band_invites(Base):
    __tablename__="band_invites"
    __table_args__ = (UniqueConstraint("band_id", "musician_id", name="uq_invite_band_musician"),)
    invite_id=Column(Integer,primary_key=True)
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),nullable=False,index=True)
    musician_id=Column(Integer,nullable=False)