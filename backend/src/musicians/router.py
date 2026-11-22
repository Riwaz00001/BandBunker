from fastapi import APIRouter,Depends, status,File, UploadFile,Form
from sqlalchemy.orm import Session
from src.musicians.dtos import registration_info,registration_response,login_info,post_response,profile_response,public_profile_response
from src.musicians.models import musicians,posts,profile_info
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.controller import register_musician,login_musician,create_post,get_my_posts,get_all_posts,get_my_profile,update_profile,get_profile_by_id


musicians_router=APIRouter(prefix="/musician")

@musicians_router.post("/register",response_model=registration_response,status_code=status.HTTP_201_CREATED)
def register(user:registration_info,db:Session=Depends(get_db)):
    return register_musician(user,db)

@musicians_router.post("/login",status_code=status.HTTP_200_OK)
def login(user:login_info,db:Session=Depends(get_db)):
    return login_musician(user,db)

#posts
@musicians_router.post("/posts/create_post",response_model=post_response)
def upload_post(caption:str=Form(""),file:UploadFile=File(...),user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return create_post(caption,file,user,db)

@musicians_router.get("/posts/my_posts",response_model=list[post_response])
def my_posts(user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return get_my_posts(user,db)

@musicians_router.get("/posts/all_posts",response_model=list[post_response])
def all_posts(user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return get_all_posts(db)

#profile 
@musicians_router.get("/profile",response_model=profile_response)
def my_profile(user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return get_my_profile(user,db)

@musicians_router.put("/profile",response_model=profile_response)
def edit_profile(bio:str|None=Form(None),file:UploadFile|None=File(None),user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return update_profile(bio,file,user,db)

@musicians_router.get("/profile/{musician_id}",response_model=public_profile_response,dependencies=[Depends(authenticated_musician)])
def view_profile(musician_id:int, db:Session=Depends(get_db)):
    return get_profile_by_id(musician_id,db)