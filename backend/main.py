from fastapi import FastAPI
from src.utils.db import Base,engine
from src.musicians.models import musicians
from src.room_owner.models import owners,Room,Booking
from src.bands.models import bands,band_members,band_invites
from src.musicians.router import musicians_router
from src.room_owner.router import owners_router,rooms_router,bookings_router
from src.bands.router import bands_router
Base.metadata.create_all(engine)
app=FastAPI()
@app.get("/")
def home():
    return "Server On!!"

app.include_router(owners_router)
app.include_router(rooms_router)
app.include_router(bookings_router)
app.include_router(musicians_router)
app.include_router(bands_router)
