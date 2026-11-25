from fastapi import APIRouter, Depends,status,File,UploadFile,Form
from sqlalchemy.orm import Session
from src.bands.dtos import band_response,band_members_response,invite_response,band_post_response
from src.bands.models import bands,band_members,band_invites
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.models import musicians
from src.bands.controller import make_band,update_band,get_my_band,get_band_by_id,get_band_members,get_my_bands,get_invites,reject_invite,send_invite,accept_invite,create_band_post,get_band_posts,get_all_band_posts,create_join_request,get_join_requests,accept_join_request,reject_join_request
bands_router=APIRouter(prefix="/bands")

# Fixed paths MUST come before /{band_id}
@bands_router.get("/mine", response_model=list[band_response])
def my_bands(user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return get_my_bands(user, db)

@bands_router.get("/invites", response_model=list[invite_response])
def my_invites(user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return get_invites(user, db)

@bands_router.get("/{band_id}", response_model=band_response)
def get_band(band_id: int, db: Session = Depends(get_db), user: musicians = Depends(authenticated_musician)):
    return get_band_by_id(band_id, db)

@bands_router.get("/{band_id}/members", response_model=band_members_response)
def band_members(band_id: int, db: Session = Depends(get_db), user: musicians = Depends(authenticated_musician)):
    return get_band_members(band_id, db)

@bands_router.delete("/invites/{invite_id}", status_code=status.HTTP_204_NO_CONTENT)
def reject_invite_route(invite_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return reject_invite(invite_id, user, db)

@bands_router.put("/invites/{invite_id}/accept", response_model=band_response)
def accept_invite_route(invite_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return accept_invite(invite_id, user, db)

@bands_router.post("/invite/{musician_id}", response_model=invite_response)
def invite_musician(musician_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return send_invite(musician_id, user, db)

@bands_router.post("/create",response_model=band_response,status_code=status.HTTP_201_CREATED)
def create_band(band_name:str=Form(...),description:str|None=Form(None),genre:str=Form(...),file:UploadFile|None=File(None),user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return make_band(band_name,description,genre,file,user,db)


@bands_router.get("/my_band", response_model=band_response)
def my_band(user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return get_my_band(user, db)


@bands_router.put("/{band_id}", response_model=band_response)
def edit_band(band_id: int,band_name: str | None = Form(None),description: str | None = Form(None),genre: str | None = Form(None),file: UploadFile | None = File(None),user: musicians = Depends(authenticated_musician),db:Session=Depends(get_db)):
     return update_band(band_id, band_name, description, genre, file, user, db)


@bands_router.post("/{band_id}/posts", response_model=band_post_response, status_code=status.HTTP_201_CREATED)
def add_band_post(band_id: int, caption: str = Form(""), file: UploadFile = File(...), user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return create_band_post(band_id, caption, file, user, db)


@bands_router.get("/posts/all", response_model=list[band_post_response])
def all_band_posts(db: Session = Depends(get_db), user: musicians = Depends(authenticated_musician)):
    return get_all_band_posts(db)
@bands_router.post("/{band_id}/join-requests", response_model=dict)
def create_join_req(band_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return create_join_request(band_id, user, db)

@bands_router.get("/join-requests", response_model=list[join_request_response])
def list_join_reqs(user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return get_join_requests(user, db)

@bands_router.post("/join-requests/{request_id}/accept", response_model=dict)
def accept_join_req(request_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return accept_join_request(request_id, user, db)

@bands_router.delete("/join-requests/{request_id}", response_model=dict)
def reject_join_req(request_id: int, user: musicians = Depends(authenticated_musician), db: Session = Depends(get_db)):
    return reject_join_request(request_id, user, db)
def list_band_posts(band_id: int, db: Session = Depends(get_db), user: musicians = Depends(authenticated_musician)):
    return get_band_posts(band_id, db)