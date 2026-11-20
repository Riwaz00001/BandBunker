from fastapi import status,Request, Depends,HTTPException
from src.utils.db import get_db
from sqlalchemy.orm import Session
import jwt
from jwt import InvalidTokenError
from src.utils.settings import settings
from src.musicians.models import musicians
from src.room_owner.models import owners
def authenticated_musician(request:Request,db=Depends(get_db)):
    try:
        token=request.headers.get("authorization")
        if not token:
           raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized") 
        token=token.split(" ")[-1]
        data=jwt.decode(token,settings.SECRET_KEY,settings.ALGORITHM)
        user_id=data.get("user_id")
        musician=db.query(musicians).filter(musicians.musician_id==user_id).first()
        if not musician:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized")
        return musician
    except InvalidTokenError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized")

def authenticated_owner(request:Request,db=Depends(get_db)):
    try:
        token=request.headers.get("authorization")
        if not token:
           raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized") 
        token=token.split(" ")[-1]
        data=jwt.decode(token,settings.SECRET_KEY,settings.ALGORITHM)
        user_id=data.get("user_id")
        owner=db.query(owners).filter(owners.owner_id==user_id).first()
        if not owner:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized")
        return owner
    except InvalidTokenError:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,detail="Unauthorized")
