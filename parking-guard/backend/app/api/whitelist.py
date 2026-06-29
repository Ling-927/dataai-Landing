from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, List
from ..core.database import get_db
from ..models.models import WhitelistPlate
from .auth import get_current_user

router = APIRouter(prefix="/whitelist", tags=["whitelist"])


class PlateCreate(BaseModel):
    plate_number: str
    owner_name: Optional[str] = None
    vehicle_make: Optional[str] = None
    vehicle_model: Optional[str] = None
    vehicle_color: Optional[str] = None
    notes: Optional[str] = None


class PlateUpdate(PlateCreate):
    is_active: Optional[bool] = None


@router.get("/", response_model=List[dict])
def list_plates(db: Session = Depends(get_db), _=Depends(get_current_user)):
    plates = db.query(WhitelistPlate).order_by(WhitelistPlate.created_at.desc()).all()
    return [
        {
            "id": p.id,
            "plate_number": p.plate_number,
            "owner_name": p.owner_name,
            "vehicle_make": p.vehicle_make,
            "vehicle_model": p.vehicle_model,
            "vehicle_color": p.vehicle_color,
            "notes": p.notes,
            "is_active": p.is_active,
            "created_at": p.created_at,
        }
        for p in plates
    ]


@router.post("/", status_code=201)
def add_plate(data: PlateCreate, db: Session = Depends(get_db), user=Depends(get_current_user)):
    normalized = data.plate_number.upper().replace(" ", "").replace("-", "")
    if db.query(WhitelistPlate).filter(WhitelistPlate.plate_number == normalized).first():
        raise HTTPException(400, "Plate already in whitelist")
    plate = WhitelistPlate(
        plate_number=normalized,
        owner_name=data.owner_name,
        vehicle_make=data.vehicle_make,
        vehicle_model=data.vehicle_model,
        vehicle_color=data.vehicle_color,
        notes=data.notes,
        created_by=user.id,
    )
    db.add(plate)
    db.commit()
    db.refresh(plate)
    return {"message": "Plate added", "id": plate.id}


@router.put("/{plate_id}")
def update_plate(plate_id: int, data: PlateUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    plate = db.query(WhitelistPlate).filter(WhitelistPlate.id == plate_id).first()
    if not plate:
        raise HTTPException(404, "Plate not found")
    for field, val in data.dict(exclude_unset=True).items():
        if field == "plate_number" and val:
            val = val.upper().replace(" ", "").replace("-", "")
        setattr(plate, field, val)
    db.commit()
    return {"message": "Updated"}


@router.delete("/{plate_id}")
def delete_plate(plate_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    plate = db.query(WhitelistPlate).filter(WhitelistPlate.id == plate_id).first()
    if not plate:
        raise HTTPException(404, "Plate not found")
    db.delete(plate)
    db.commit()
    return {"message": "Deleted"}


@router.get("/check/{plate_number}")
def check_plate(plate_number: str, db: Session = Depends(get_db)):
    normalized = plate_number.upper().replace(" ", "").replace("-", "")
    entry = db.query(WhitelistPlate).filter(
        WhitelistPlate.plate_number == normalized,
        WhitelistPlate.is_active == True,
    ).first()
    return {"plate": normalized, "whitelisted": entry is not None}
