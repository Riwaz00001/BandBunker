from src.utils.db import Base
from sqlalchemy import Column,Integer, String, DateTime,ForeignKey,func,Text

class musicians(Base):
    __tablename__="musicians"
    musician_id=Column(Integer,primary_key=True)
    name=Column(String,nullable=False)
    email=Column(String,nullable=False)
    password=Column(String,nullable=False)
    role=Column(String,nullable=False)

class posts(Base):
    __tablename__ = "posts"
    post_id = Column(Integer, primary_key=True)
    musician_id = Column(Integer, ForeignKey("musicians.musician_id", ondelete="CASCADE"), nullable=False, index=True)
    musician_name = Column(String, nullable=False)
    caption = Column(Text, nullable=True)
    file_path = Column(String, nullable=False)
    media_type = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

class profile_info(Base):
    __tablename__="profile_info"
    musician_id=Column(Integer,ForeignKey("musicians.musician_id",ondelete="CASCADE"),primary_key=True)
    bio=Column(String,nullable=True)
    profile_pic_path=Column(String,nullable=True)