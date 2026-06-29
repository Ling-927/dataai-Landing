import { useEffect, useRef, useState, useCallback } from "react";

const WS_URL = process.env.REACT_APP_WS_URL || "ws://localhost:8000/api/stream/ws";

export function useDetectionStream(onEvent: (data: any) => void) {
  const ws = useRef<WebSocket | null>(null);
  const [connected, setConnected] = useState(false);

  const connect = useCallback(() => {
    try {
      ws.current = new WebSocket(WS_URL);
      ws.current.onopen = () => setConnected(true);
      ws.current.onclose = () => {
        setConnected(false);
        setTimeout(connect, 3000);
      };
      ws.current.onmessage = (e) => {
        try {
          const msg = JSON.parse(e.data);
          if (msg.type === "detection") onEvent(msg.data);
        } catch {}
      };
    } catch (err) {
      setTimeout(connect, 5000);
    }
  }, [onEvent]);

  useEffect(() => {
    connect();
    return () => ws.current?.close();
  }, [connect]);

  return { connected };
}
