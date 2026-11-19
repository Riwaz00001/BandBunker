from fastapi import APIRouter,Depends, status,File, UploadFile,Form
from sqlalchemy.orm import Session
from src.musicians.dtos import registration_info,registration_response,login_info,post_response
from src.musicians.models import musicians
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.controller import register_musician,login_musician,create_post


musicians_router=APIRouter(prefix="/musician")

@musicians_router.post("/register",response_model=registration_response,status_code=status.HTTP_201_CREATED)
def register(user:registration_info,db:Session=Depends(get_db)):
    return register_musician(user,db)

@musicians_router.post("/login",status_code=status.HTTP_200_OK)
def register(user:login_info,db:Session=Depends(get_db)):
    return login_musician(user,db)

@musicians_router.post("/posts/create_post",response_model=post_response)
def upload_post(caption:str=Form(""),file:UploadFile=File(...),user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return create_post(caption,file,user,db)