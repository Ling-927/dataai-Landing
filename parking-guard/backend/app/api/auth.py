from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional

from ..core.database import get_db
from ..core.security import verify_password, get_password_hash, create_access_token, decode_token
from ..models.models import User

router = APIRouter(prefix="/auth", tags=["auth"])
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")


class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    whatsapp_number: Optional[str] = None


class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: int
    username: str
    is_owner: bool


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    payload = decode_token(token)
    if not payload:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    user = db.query(User).filter(User.id == payload.get("sub")).first()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user


@router.post("/register", status_code=201)
def register(data: UserCreate, db: Session = Depends(get_db)):
    if db.query(User).filter(User.username == data.username).first():
        raise HTTPException(400, "Username already taken")
    user = User(
        username=data.username,
        email=data.email,
        hashed_password=get_password_hash(data.password),
        whatsapp_number=data.whatsapp_number,
        is_owner=db.query(User).count() == 0,  # first user is owner
    )
    db.add(user)
    db.commit()
    return {"message": "Account created", "is_owner": user.is_owner}


@router.post("/login", response_model=Token)
def login(form: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == form.username).first()
    if not user or not verify_password(form.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Wrong credentials")
    token = create_access_token({"sub": user.id})
    return Token(
        access_token=token,
        token_type="bearer",
        user_id=user.id,
        username=user.username,
        is_owner=user.is_owner,
    )


@router.get("/me")
def get_me(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "is_owner": current_user.is_owner,
        "whatsapp_number": current_user.whatsapp_number,
    }
