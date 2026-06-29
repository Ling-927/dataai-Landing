import React, { useState, useCallback } from "react";
import { useQuery } from "@tanstack/react-query";
import { ShieldCheck, AlertTriangle, Car, Users, Wifi, WifiOff } from "lucide-react";
import toast from "react-hot-toast";
import { getStats, getEvents, acknowledgeEvent } from "../utils/api";
import { useDetectionStream } from "../hooks/useWebSocket";
import { format } from "date-fns";

export default function Dashboard() {
  const [liveEvents, setLiveEvents] = useState<any[]>([]);

  const { data: stats } = useQuery({ queryKey: ["stats"], queryFn: () => getStats().then((r) => r.data), refetchInterval: 10000 });
  const { data: events, refetch } = useQuery({ queryKey: ["events"], queryFn: () => getEvents({ limit: 20 }).then((r) => r.data), refetchInterval: 15000 });

  const onEvent = useCallback((data: any) => {
    setLiveEvents((prev) => [data, ...prev].slice(0, 5));
    if (data.alert_triggered) {
      toast.error(`🚨 AMARAN! Plat: ${data.plate || "TIDAK DIKESAN"} — ${data.vehicle_type || "Kenderaan"} ${data.color || ""}`, { duration: 8000 });
    }
    refetch();
  }, [refetch]);

  const { connected } = useDetectionStream(onEvent);

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Dashboard I Defender</h1>
        <div className="flex items-center gap-2 text-sm">
          {connected ? <><Wifi size={16} className="text-green-500" /> <span className="text-green-600">Live</span></> : <><WifiOff size={16} className="text-red-500" /><span className="text-red-500">Offline</span></>}
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard icon={<Car className="text-blue-500" />} label="Jumlah Kesan" value={stats?.total ?? 0} color="blue" />
        <StatCard icon={<AlertTriangle className="text-red-500" />} label="Amaran" value={stats?.alerts ?? 0} color="red" />
        <StatCard icon={<ShieldCheck className="text-green-500" />} label="Dibenarkan" value={stats?.whitelisted ?? 0} color="green" />
        <StatCard icon={<Users className="text-yellow-500" />} label="Tidak Dikenal" value={stats?.unknown ?? 0} color="yellow" />
      </div>

      {/* Live Events */}
      {liveEvents.length > 0 && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4">
          <h2 className="font-semibold text-red-700 mb-3">🔴 Pengesanan Langsung</h2>
          <div className="space-y-2">
            {liveEvents.map((e, i) => (
              <div key={i} className={`flex items-center gap-3 p-3 rounded-lg ${e.alert_triggered ? "bg-red-100" : "bg-green-50"}`}>
                {e.alert_triggered ? <AlertTriangle size={18} className="text-red-500" /> : <ShieldCheck size={18} className="text-green-500" />}
                <div>
                  <span className="font-mono font-bold">{e.plate || "—"}</span>
                  <span className="ml-2 text-sm text-gray-600">{e.vehicle_color} {e.vehicle_type}</span>
                  {e.face_name && <span className="ml-2 text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded">Muka: {e.face_name}</span>}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Event Log */}
      <div className="bg-white rounded-xl shadow-sm border">
        <div className="px-4 py-3 border-b"><h2 className="font-semibold">Log Kejadian Terkini</h2></div>
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 text-gray-500 text-xs uppercase">
              <tr>
                <th className="px-4 py-2 text-left">Masa</th>
                <th className="px-4 py-2 text-left">Plat</th>
                <th className="px-4 py-2 text-left">Warna / Jenis</th>
                <th className="px-4 py-2 text-left">Muka</th>
                <th className="px-4 py-2 text-left">Status</th>
                <th className="px-4 py-2 text-left">Tindakan</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {events?.map((e: any) => (
                <tr key={e.id} className={e.alert_triggered ? "bg-red-50" : ""}>
                  <td className="px-4 py-2 text-gray-500">{format(new Date(e.timestamp), "dd/MM HH:mm:ss")}</td>
                  <td className="px-4 py-2 font-mono font-semibold">{e.plate_number || "—"}</td>
                  <td className="px-4 py-2">{e.vehicle_color} {e.vehicle_model}</td>
                  <td className="px-4 py-2">{e.face_name || "—"}</td>
                  <td className="px-4 py-2">
                    {e.is_whitelisted ? (
                      <span className="bg-green-100 text-green-700 text-xs px-2 py-0.5 rounded-full">Dibenarkan</span>
                    ) : e.alert_triggered ? (
                      <span className="bg-red-100 text-red-700 text-xs px-2 py-0.5 rounded-full">Amaran</span>
                    ) : (
                      <span className="bg-gray-100 text-gray-600 text-xs px-2 py-0.5 rounded-full">Biasa</span>
                    )}
                  </td>
                  <td className="px-4 py-2">
                    {e.alert_status === "pending" || e.alert_status === "notified" ? (
                      <button onClick={() => acknowledgeEvent(e.id).then(() => refetch())}
                        className="text-xs bg-blue-100 text-blue-700 px-2 py-1 rounded hover:bg-blue-200">
                        Akui
                      </button>
                    ) : null}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

function StatCard({ icon, label, value, color }: any) {
  const colors: any = { blue: "bg-blue-50 border-blue-200", red: "bg-red-50 border-red-200", green: "bg-green-50 border-green-200", yellow: "bg-yellow-50 border-yellow-200" };
  return (
    <div className={`${colors[color]} border rounded-xl p-4 flex items-center gap-3`}>
      <div className="text-2xl">{icon}</div>
      <div>
        <div className="text-2xl font-bold">{value}</div>
        <div className="text-xs text-gray-500">{label}</div>
      </div>
    </div>
  );
}
