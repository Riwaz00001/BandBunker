from fastapi import File,UploadFile,HTTPException
from sqlalchemy.orm import Session
from supabase import Client ,create_client
from src.utils.settings import settings
from src.bands.models import bands,band_members
from src.musicians.models import musicians
import uuid 
supabase: Client=create_client(settings.supabase_url,settings.supabase_key)
PIC_TYPES={"image/jpeg","image/png","image/webp"}
MAX_PIC=5*1024*1024

def pic_url(path:str|None):
    return supabase.storage.from_(settings.bucket).get_public_url(path) if path else None

def save_pic(file:UploadFile)->str:
    if file.content_type not in PIC_TYPES:
        raise HTTPException(400,"Must be jpg,png or webp")
    content=file.file.read()
    if len(content)>MAX_PIC:
        raise HTTPException(413,"Image to large")
    ext = (file.filename or "").rsplit(".", 1)[-1].lower() or "jpg"
    path = f"bands/{uuid.uuid4()}.{ext}"
    try:
        supabase.storage.from_(settings.bucket).upload(
            path=path, file=content,
            file_options={"content-type": file.content_type},
        )
    except Exception as e:
        print("storage error:", e)
        raise HTTPException(502, "Upload failed")
    return path


def band_out(b: bands) -> dict:
    return {
        "band_id": b.band_id,
        "band_name": b.band_name,
        "description": b.description,
        "genre": b.genre,
        "profile_pic_url": pic_url(b.profile_pic_path),
        "owner_id": b.owner_id,
    }

def make_band(name:str,description:str|None,genre:str,file:UploadFile|None,user:musicians,db:Session):
    path = save_pic(file) if file else None
    try:
        band = bands(band_name=name.strip(),description=description,profile_pic_path=path,genre=genre, owner_id=user.musician_id)
        db.add(band)
        db.flush()                   
        db.add(band_members(band_id=band.band_id, musician_id=user.musician_id,role="owner"))
        db.commit()
        db.refresh(band)
    except Exception as e:
        db.rollback()
        if path:
            supabase.storage.from_(settings.bucket).remove([path])
        print("db error:", e)
        raise HTTPException(500, "Could not create band")
    return band_out(band)