from fastapi import APIRouter, Depends,status,File,UploadFile,Form
from sqlalchemy.orm import Session
from src.bands.dtos import band_response
from src.bands.models import bands,band_members
from src.utils.db import get_db
from src.utils.auth import authenticated_musician
from src.musicians.models import musicians
from src.bands.controller import make_band
bands_router=APIRouter(prefix="/bands")

@bands_router.post("/create",response_model=band_response,status_code=status.HTTP_201_CREATED)
def create_band(band_name:str=Form(...),description:str|None=Form(None),genre:str=Form(...),file:UploadFile|None=File(None),user:musicians=Depends(authenticated_musician),db:Session=Depends(get_db)):
    return make_band(band_name,description,genre,file,user,db)