from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.room_owner.dtos import registration_info,login_info
from src.room_owner.models import owners
from pwdlib import PasswordHash
import jwt
from datetime import datetime,timedelta
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
    owner=owners(name=user.name,studio=user.studio,email=user.email,number=user.number,location=user.location,room_type=user.room_type,password=password,)
    db.add(owner)
    db.commit()
    db.refresh(owner)
    return owner

def login_owner(user:login_info,db:Session=Depends(get_db)):
    correct_user=db.query(owners).filter(user.email==owners.email).first()
    correct_password=verify_password(user.password,correct_user.password)
    if correct_user and correct_password:
        exp_time=datetime.now()+timedelta(days=settings.EXP_TIME)
        token=jwt.encode({"user_id":correct_user.owner_id,"exp_time":exp_time.timestamp()},settings.SECRET_KEY,settings.ALGORITHM)
        return {"token":token}
    raise HTTPException(status_code=401,detail="Incorrect password or username")