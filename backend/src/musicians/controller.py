from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.musicians.dtos import registration_info
from src.musicians.models import musicians
from pwdlib import PasswordHash
password_hash=PasswordHash.recommended()
def get_hashed_password(password):
    return password_hash.hash(password)


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
