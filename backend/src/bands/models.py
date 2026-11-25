from sqlalchemy.orm import Session
from src.utils.db import Base
from sqlalchemy import ForeignKey, Column, Integer, String, DateTime, func
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
    invite_id=Column(Integer,primary_key=True)
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),nullable=False,index=True)
    musician_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),nullable=False,index=True)
    created_at=Column(DateTime(timezone=True),server_default=func.now())

class band_join_requests(Base):
    __tablename__="band_join_requests"
    request_id=Column(Integer,primary_key=True)
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),nullable=False,index=True)
    musician_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),nullable=False,index=True)
    created_at=Column(DateTime(timezone=True),server_default=func.now())
    __tablename__="band_posts"
    post_id=Column(Integer,primary_key=True)
    band_id=Column(Integer,ForeignKey("bands.band_id",ondelete="CASCADE"),nullable=False,index=True)
    caption=Column(String,nullable=True)
    file_path=Column(String,nullable=False)
    media_type=Column(String,nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)