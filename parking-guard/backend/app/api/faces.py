import os
import io
import pickle
import numpy as np
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form
from sqlalchemy.orm import Session
from typing import List
from PIL import Image
from ..core.database import get_db
from ..models.models import FaceProfile
from ..core.config import settings
from .auth import get_current_user

router = APIRouter(prefix="/faces", tags=["faces"])


def _get_ai():
    from ..main import ai_service
    return ai_service


@router.get("/", response_model=List[dict])
def list_faces(db: Session = Depends(get_db), _=Depends(get_current_user)):
    profiles = db.query(FaceProfile).order_by(FaceProfile.created_at.desc()).all()
    return [
        {
            "id": p.id,
            "name": p.name,
            "is_owner": p.is_owner,
            "is_active": p.is_active,
            "photo_path": p.photo_path,
            "created_at": p.created_at,
        }
        for p in profiles
    ]


@router.post("/", status_code=201)
async def add_face(
    name: str = Form(...),
    is_owner: bool = Form(False),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    user=Depends(get_current_user),
):
    ai = _get_ai()
    contents = await file.read()
    img = Image.open(io.BytesIO(contents)).convert("RGB")
    img_np = np.array(img)[:, :, ::-1]  # RGB to BGR

    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
    photo_path = os.path.join(settings.UPLOAD_DIR, f"face_{name}_{file.filename}")
    img.save(photo_path)

    success = ai.add_face(name, img_np, is_owner=is_owner)
    if not success:
        raise HTTPException(400, "No face detected in image")

    ai.save_face_encodings(settings.FACE_ENCODINGS_PATH)

    profile = FaceProfile(
        name=name,
        is_owner=is_owner,
        photo_path=photo_path,
        created_by=user.id,
    )
    db.add(profile)
    db.commit()
    return {"message": "Face profile added", "id": profile.id}


@router.delete("/{face_id}")
def delete_face(face_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    profile = db.query(FaceProfile).filter(FaceProfile.id == face_id).first()
    if not profile:
        raise HTTPException(404, "Profile not found")
    ai = _get_ai()
    if profile.name in ai.face_names:
        idx = ai.face_names.index(profile.name)
        ai.face_names.pop(idx)
        ai.known_encodings.pop(idx)
        if hasattr(ai, "owner_flags") and idx < len(ai.owner_flags):
            ai.owner_flags.pop(idx)
        ai.save_face_encodings(settings.FACE_ENCODINGS_PATH)
    db.delete(profile)
    db.commit()
    return {"message": "Deleted"}
