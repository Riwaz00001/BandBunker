from fastapi import APIRouter,Depends, status
from sqlalchemy.orm import Session
from src.musicians.dtos import registration_info,registration_response
from src.utils.db import get_db
from src.musicians.controller import register_musician


musicians_router=APIRouter(prefix="/musician")

@musicians_router.post("/register",response_model=registration_response,status_code=status.HTTP_201_CREATED)
def register(user:registration_info,db:Session=Depends(get_db)):
    return register_musician(user,db)