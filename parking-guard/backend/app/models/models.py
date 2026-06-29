from sqlalchemy import Column, Integer, String, Boolean, DateTime, Float, Text, ForeignKey, Enum
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import enum
from ..core.database import Base


class AlertStatus(str, enum.Enum):
    PENDING = "pending"
    NOTIFIED = "notified"
    ACKNOWLEDGED = "acknowledged"
    DISMISSED = "dismissed"


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    is_active = Column(Boolean, default=True)
    is_owner = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    whatsapp_number = Column(String, nullable=True)


class WhitelistPlate(Base):
    __tablename__ = "whitelist_plates"
    id = Column(Integer, primary_key=True, index=True)
    plate_number = Column(String, unique=True, index=True, nullable=False)
    owner_name = Column(String, nullable=True)
    vehicle_make = Column(String, nullable=True)
    vehicle_model = Column(String, nullable=True)
    vehicle_color = Column(String, nullable=True)
    notes = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)


class FaceProfile(Base):
    __tablename__ = "face_profiles"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    encoding_path = Column(String, nullable=True)
    photo_path = Column(String, nullable=True)
    is_owner = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    created_by = Column(Integer, ForeignKey("users.id"), nullable=True)


class DetectionEvent(Base):
    __tablename__ = "detection_events"
    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
    plate_number = Column(String, nullable=True)
    plate_confidence = Column(Float, nullable=True)
    vehicle_make = Column(String, nullable=True)
    vehicle_model = Column(String, nullable=True)
    vehicle_color = Column(String, nullable=True)
    face_recognized = Column(Boolean, default=False)
    face_name = Column(String, nullable=True)
    is_whitelisted = Column(Boolean, default=False)
    alert_triggered = Column(Boolean, default=False)
    alert_status = Column(Enum(AlertStatus), default=AlertStatus.PENDING)
    image_path = Column(String, nullable=True)
    video_clip_path = Column(String, nullable=True)
    whatsapp_sent = Column(Boolean, default=False)
    zone = Column(String, nullable=True)
    notes = Column(Text, nullable=True)


class SystemSetting(Base):
    __tablename__ = "system_settings"
    id = Column(Integer, primary_key=True)
    key = Column(String, unique=True, nullable=False)
    value = Column(Text, nullable=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())


class Zone(Base):
    __tablename__ = "zones"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(Text, nullable=True)
    coordinates = Column(Text, nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
