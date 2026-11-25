from fastapi import File,UploadFile,HTTPException,status
from sqlalchemy.orm import Session
from supabase import Client ,create_client
from src.utils.settings import settings
from src.bands.models import bands,band_members,band_invites,band_post
from src.musicians.models import musicians,profile_info
import uuid 
supabase: Client=create_client(settings.supabase_url,settings.supabase_key)
PIC_TYPES={"image/jpeg","image/png","image/webp"}
MAX_PIC=5*1024*1024

POST_ALLOWED = {
    "image/jpeg": "image",
    "image/png": "image",
    "image/webp": "image",
    "video/mp4": "video",
    "video/quicktime": "video",
}
POST_MAX_SIZE = 50 * 1024 * 1024

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

def member_out(m: musicians, p: profile_info | None, role: str) -> dict:
    return {
        "musician_id": m.musician_id,
        "name": m.name,
        "role": role,
        "profile_pic_url": pic_url(p.profile_pic_path) if p else None,
    }

def invite_out(inv: band_invites, band: bands) -> dict:
    return {
        "invite_id": inv.invite_id,
        "band_id": band.band_id,
        "band_name": band.band_name,
        "profile_pic_url": pic_url(band.profile_pic_path),
        "musician_id": inv.musician_id,
        "created_at": inv.created_at,
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

def get_band_by_id(band_id: int, db: Session):
    band = db.get(bands, band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    return band_out(band)

def get_band_members(band_id: int, db: Session):
    band = db.get(bands, band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    rows = (
        db.query(band_members, musicians, profile_info)
        .join(musicians, musicians.musician_id == band_members.musician_id)
        .outerjoin(profile_info, profile_info.musician_id == musicians.musician_id)
        .filter(band_members.band_id == band_id)
        .all()
    )
    members = [
        member_out(m, prof, bm.role)
        for bm, m, prof in rows
    ]
    members.sort(key=lambda x: (0 if x["role"] == "owner" else 1, x["name"].lower()))
    return {"members": members}

def get_my_bands(user: musicians, db: Session):
    rows = (
        db.query(bands)
        .join(band_members, band_members.band_id == bands.band_id)
        .filter(band_members.musician_id == user.musician_id)
        .order_by(bands.band_id.desc())
        .all()
    )
    return [band_out(b) for b in rows]

def get_invites(user: musicians, db: Session):
    rows = (
        db.query(band_invites, bands)
        .join(bands, bands.band_id == band_invites.band_id)
        .filter(band_invites.musician_id == user.musician_id)
        .all()
    )
    return [invite_out(inv, band) for inv, band in rows]

def reject_invite(invite_id: int, user: musicians, db: Session):
    inv = db.get(band_invites, invite_id)
    if not inv or inv.musician_id != user.musician_id:
        raise HTTPException(404, "Invite not found")
    db.delete(inv)
    db.commit()

def accept_invite(invite_id: int, user: musicians, db: Session):
    inv = db.get(band_invites, invite_id)
    if not inv or inv.musician_id != user.musician_id:
        raise HTTPException(404, "Invite not found")
    
    band = db.get(bands, inv.band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    
    # Check if already a member
    existing = db.query(band_members).filter(
        band_members.band_id == band.band_id,
        band_members.musician_id == user.musician_id
    ).first()
    if existing:
        db.delete(inv)
        db.commit()
        raise HTTPException(409, "Already a member")
    
    # Add as member
    db.add(band_members(band_id=band.band_id, musician_id=user.musician_id, role="member"))
    db.delete(inv)
    db.commit()
    db.refresh(band)
    return band_out(band)

def send_invite(musician_id: int, user: musicians, db: Session):
    if musician_id == user.musician_id:
        raise HTTPException(400, "You cannot invite yourself")
    
    target = db.get(musicians, musician_id)
    if not target:
        raise HTTPException(404, "Musician not found")
    
    band = db.query(bands).filter(bands.owner_id == user.musician_id).first()
    if not band:
        raise HTTPException(403, "You don't own a band")
    
    existing_member = db.query(band_members).filter(
        band_members.band_id == band.band_id,
        band_members.musician_id == musician_id
    ).first()
    if existing_member:
        raise HTTPException(409, "Already a member of your band")
    
    existing_invite = db.query(band_invites).filter(
        band_invites.band_id == band.band_id,
        band_invites.musician_id == musician_id
    ).first()
    if existing_invite:
        raise HTTPException(409, "Invite already sent")
    
    invite = band_invites(band_id=band.band_id, musician_id=musician_id)
    db.add(invite)
    db.commit()
    db.refresh(invite)
    return invite_out(invite, band)

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


def band_post_out(p: band_post) -> dict:
    return {
        "post_id": p.post_id,
        "band_id": p.band_id,
        "caption": p.caption,
        "media_type": p.media_type,
        "media_url": supabase.storage.from_(settings.bucket).get_public_url(p.file_path),
        "created_at": p.created_at,
    }


def create_band_post(band_id: int, caption: str, file: UploadFile, user: musicians, db: Session):
    band = db.get(bands, band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    if band.owner_id != user.musician_id:
        raise HTTPException(403, "Only the band owner can add posts")

    media_type = POST_ALLOWED.get(file.content_type)
    if not media_type:
        raise HTTPException(400, "Unsupported File")
    content = file.file.read()
    if len(content) > POST_MAX_SIZE:
        raise HTTPException(413, "File too large")
    ext = (file.filename or "").rsplit(".", 1)[-1].lower() or "bin"
    file_path = f"bands/posts/{uuid.uuid4()}.{ext}"

    try:
        supabase.storage.from_(settings.bucket).upload(path=file_path, file=content, file_options={"content-type": file.content_type})
    except Exception as e:
        raise HTTPException(502, "Upload Failed")

    try:
        post = band_post(band_id=band_id, caption=caption, file_path=file_path, media_type=media_type)
        db.add(post)
        db.commit()
        db.refresh(post)
    except Exception as e:
        db.rollback()
        supabase.storage.from_(settings.bucket).remove([file_path])
        raise HTTPException(500, "Could not save post")

    return band_post_out(post)


def get_band_posts(band_id: int, db: Session):
    band = db.get(bands, band_id)
    if not band:
        raise HTTPException(404, "Band not found")
    rows = (
        db.query(band_post)
        .filter(band_post.band_id == band_id)
        .order_by(band_post.created_at.desc())
        .all()
    )
    return [band_post_out(p) for p in rows]