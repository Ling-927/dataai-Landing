"""
WebSocket endpoint for real-time camera stream and live detection events.
"""
import asyncio
import json
import logging
from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import List

router = APIRouter(prefix="/stream", tags=["stream"])
logger = logging.getLogger(__name__)

active_connections: List[WebSocket] = []


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    try:
        while True:
            data = await websocket.receive_text()
            # Client can send commands like {"cmd": "ping"}
            msg = json.loads(data)
            if msg.get("cmd") == "ping":
                await websocket.send_json({"type": "pong"})
    except WebSocketDisconnect:
        active_connections.remove(websocket)
    except Exception as e:
        logger.error(f"WebSocket error: {e}")
        if websocket in active_connections:
            active_connections.remove(websocket)


async def broadcast_event(event_data: dict):
    """Called by detection service to push events to all connected clients."""
    disconnected = []
    for ws in active_connections:
        try:
            await ws.send_json({"type": "detection", "data": event_data})
        except Exception:
            disconnected.append(ws)
    for ws in disconnected:
        active_connections.remove(ws)


async def broadcast_alert(plate: str, color: str, vehicle_type: str):
    await broadcast_event({
        "alert": True,
        "plate": plate,
        "color": color,
        "vehicle_type": vehicle_type,
    })
