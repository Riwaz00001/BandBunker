from fastapi import File,UploadFile,Form
from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.dtos import registration_info,login_info
from src.musicians.models import musicians,posts
from pwdlib import PasswordHash
import jwt
import uuid
from datetime import datetime,timedelta
from supabase import Client,create_client
from src.utils.settings import settings
password_hash=PasswordHash.recommended()

supabase: Client=create_client(settings.supabase_url,settings.supabase_key)


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


def to_out(p: posts) -> dict:
    return {
        "musician_name": p.musician_name,
        "caption": p.caption,
        "media_type": p.media_type,
        "media_url": supabase.storage.from_(settings.bucket).get_public_url(p.file_path),
        "created_at": p.created_at,
    }

def create_post(caption:str,file:UploadFile,user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    ALLOWED = {
    "image/jpeg": "image",
    "image/png": "image",
    "image/webp": "image",
    "video/mp4": "video",
    "video/quicktime": "video",
    }
    MAX_SIZE = 50 * 1024 * 1024
    media_type=ALLOWED.get(file.content_type)
    if not media_type:
        raise HTTPException(400,"Unsupported File")
    content=file.file.read()
    if len(content)>MAX_SIZE:
        raise HTTPException(413,"File too large")
    ext = (file.filename or "").rsplit(".", 1)[-1].lower() or "bin"
    file_path = f"uploads/{uuid.uuid4()}.{ext}"

    try:
        supabase.storage.from_(settings.bucket).upload(path=file_path,file=content,file_options={"content-type":file.content_type})
    except Exception as e:
        raise HTTPException(502,"Upload Failed")

    try:
        post=posts(musician_id=user.musician_id,
            musician_name=user.name,
            caption=caption,
            file_path=file_path,
            media_type=media_type)
        db.add(post)
        db.commit()
        db.refresh(post)
    except Exception as e:
        db.rollback()
        supabase.storage.from_(settings.bucket).remove([file_path])
        raise HTTPException(500, "Could not save post")
    return to_out(post)

#Own posts
def get_my_posts(user:musicians,db:Session):
    rows=db.query(posts).filter(posts.musician_id==user.musician_id).order_by(posts.created_at.desc()).all()
    return [to_out(p) for p in rows]

#all posts
def get_all_posts(db:Session):
    rows=db.query(posts).order_by(posts.created_at.desc()).all()
    return [to_out(p) for p in rows]