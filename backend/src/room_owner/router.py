from fastapi import APIRouter,Depends, status
from sqlalchemy.orm import Session
from src.room_owner.dtos import registration_info,registration_response,login_info
from src.utils.db import get_db
from src.room_owner.controller import register_owner,login_owner


owners_router=APIRouter(prefix="/owner")

@owners_router.post("/register",response_model=registration_response,status_code=status.HTTP_201_CREATED)
def register(user:registration_info,db:Session=Depends(get_db)):
    return register_owner(user,db)

@owners_router.post("/login",status_code=status.HTTP_200_OK)
def login(user:login_info,db:Session=Depends(get_db)):
    return login_owner(user,db)