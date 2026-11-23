from fastapi import File,UploadFile,Form
from sqlalchemy.orm import Session
from fastapi import Depends,HTTPException,status
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.dtos import registration_info,login_info
from src.musicians.models import musicians,posts,profile_info
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


def to_out(p: posts,pic_path:str|None) -> dict:
    return {
        "musician_id":p.musician_id,
        "musician_name": p.musician_name,
        "profile_pic_url":pic_url(pic_path),
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
    profile=db.get(profile_info,user.musician_id)
    return to_out(post,profile.profile_pic_path if profile else None)

#Own posts
def get_my_posts(user:musicians,db:Session):
    rows= (
        db.query(posts, profile_info.profile_pic_path)
        .outerjoin(profile_info, profile_info.musician_id == posts.musician_id)
        .filter(posts.musician_id == user.musician_id)
        .order_by(posts.created_at.desc())
        .all()
    )
    return [to_out(p,pic_path) for p,pic_path in rows]

#all posts
def get_all_posts(db:Session):
    rows=( db.query(posts, profile_info.profile_pic_path)
        .outerjoin(profile_info, profile_info.musician_id == posts.musician_id)
        .order_by(posts.created_at.desc())
        .all())
    return [to_out(p,pic) for p,pic in rows]


#profiles 
PIC_TYPES={"image/jpeg","image/png","image/webp"}
MAX_PIC=5*1024*1024

def pic_url(path:str|None):
    return supabase.storage.from_(settings.bucket).get_public_url(path) if path else None

def profile_out(m: musicians, p: profile_info | None) -> dict:
    return {
        "name": m.name,
        "email": m.email,
        "role": m.role,
        "bio": p.bio if p else None,
        "profile_pic_url": pic_url(p.profile_pic_path) if p else None,
    }

def get_my_profile(user: musicians, db: Session):
    p = db.get(profile_info, user.musician_id)
    return profile_out(user, p)

def get_profile_by_id(musician_id: int, db: Session):
    m = db.get(musicians, musician_id)
    if not m:
        raise HTTPException(404, "Musician not found")
    p = db.get(profile_info, musician_id)
    return profile_out(m, p)

def update_profile(bio: str | None, file: UploadFile | None, user: musicians, db: Session):
    p = db.get(profile_info, user.musician_id)
    if not p:
        p = profile_info(musician_id=user.musician_id)
        db.add(p)

    old_path = p.profile_pic_path
    new_path = None

    if file:
        if file.content_type not in PIC_TYPES:
            raise HTTPException(400, "Profile picture must be jpg, png or webp")
        content = file.file.read()
        if len(content) > MAX_PIC:
            raise HTTPException(413, "Image too large")

        ext = (file.filename or "").rsplit(".", 1)[-1].lower() or "jpg"
        new_path = f"profiles/{uuid.uuid4()}.{ext}"
        try:
            supabase.storage.from_(settings.bucket).upload(
                path=new_path,
                file=content,
                file_options={"content-type": file.content_type},
            )
        except Exception as e:
            print("storage error:", e)
            raise HTTPException(502, "Upload failed")
        p.profile_pic_path = new_path

    if bio is not None:
        p.bio = bio

    try:
        db.commit()
    except Exception as e:
        db.rollback()
        if new_path:
            supabase.storage.from_(settings.bucket).remove([new_path])
        print("db error:", e)
        raise HTTPException(500, "Could not save profile")

    if new_path and old_path:
        try:
            supabase.storage.from_(settings.bucket).remove([old_path])
        except Exception as e:
            print("cleanup error:", e)

    return profile_out(user, p)


