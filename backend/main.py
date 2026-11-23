from fastapi import FastAPI,HTTPException
from src.utils.db import Base,engine
from src.musicians.models import musicians
from src.room_owner.models import owners
from src.bands.models import bands,band_members
from src.musicians.router import musicians_router
from src.room_owner.router import owners_router
from src.bands.router import bands_router
Base.metadata.create_all(engine)
app=FastAPI()
@app.get("/")
def home():
    return "Server On!!"

app.include_router(owners_router)
app.include_router(musicians_router)
app.include_router(bands_router)
