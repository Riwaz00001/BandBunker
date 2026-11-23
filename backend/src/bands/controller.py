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

def get_my_band(user: musicians, db: Session):
    band = db.query(bands).filter(bands.owner_id == user.musician_id).first()
    if not band:
        raise HTTPException(404, "No band found")
    return band_out(band)

def update_band(band_id: int,band_name: str | None,description: str | None,genre: str | None,file: UploadFile | None,user: musicians,db: Session,):
    band = db.get(bands, band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    if band.owner_id != user.musician_id:
        raise HTTPException(403, "Only the band owner can edit this band")

    if band_name is not None and not band_name.strip():
        raise HTTPException(400, "Band name cannot be empty")
    if genre is not None and not genre.strip():
        raise HTTPException(400, "Genre cannot be empty")

    old_path = band.profile_pic_path
    new_path = save_pic(file) if file else None

    if new_path:
        band.profile_pic_path = new_path
    if band_name is not None:
        band.band_name = band_name.strip()
    if description is not None:
        band.description = description
    if genre is not None:
        band.genre = genre.strip()

    try:
        db.commit()
        db.refresh(band)
    except Exception as e:
        db.rollback()
        if new_path:
            supabase.storage.from_(settings.bucket).remove([new_path])
        print("db error:", e)
        raise HTTPException(500, "Could not update band")

    # delete the replaced picture only after the commit succeeded
    if new_path and old_path:
        try:
            supabase.storage.from_(settings.bucket).remove([old_path])
        except Exception as e:
            print("cleanup error:", e)

    return band_out(band)