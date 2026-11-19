from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.musicians.dtos import registration_info,login_info
from src.musicians.models import musicians
from pwdlib import PasswordHash
import jwt
from datetime import datetime,timedelta
from src.utils.settings import settings
password_hash=PasswordHash.recommended()
def get_hashed_password(password):
    return password_hash.hash(password)

def verify_password(password,hashed_password):
    return password_hash.verify(password,hashed_password)

def register_musician(user:registration_info,db:Session=Depends(get_db)):
    existing_user=db.query(musicians).filter(user.email==musicians.email).first()
    if existing_user:
        raise HTTPException(status_code=400,detail="Email already in use!")
    password=get_hashed_password(user.password)
    musician=musicians(name=user.name,email=user.email,password=password,role=user.role)
    db.add(musician)
    db.commit()
    db.refresh(musician)
    return musician

def login_musician(user:login_info,db:Session=Depends(get_db)):
    correct_user=db.query(musicians).filter(user.email==musicians.email).first()
    if not correct_user or not verify_password(user.password,correct_user.password):
        raise HTTPException(status_code=401,detail="Incorrect password or username")

    exp_time=datetime.now()+timedelta(days=settings.EXP_TIME)
    token=jwt.encode({"user_id":correct_user.musician_id,"exp_time":exp_time.timestamp()},settings.SECRET_KEY,settings.ALGORITHM)
    return {"token":token}