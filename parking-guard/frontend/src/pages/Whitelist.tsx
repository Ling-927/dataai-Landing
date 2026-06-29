import React, { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { Plus, Trash2, Edit2, CheckCircle, XCircle } from "lucide-react";
import toast from "react-hot-toast";
import { getWhitelist, addPlate, deletePlate, updatePlate } from "../utils/api";

const EMPTY_FORM = { plate_number: "", owner_name: "", vehicle_make: "", vehicle_model: "", vehicle_color: "", notes: "" };

export default function WhitelistPage() {
  const qc = useQueryClient();
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState(EMPTY_FORM);
  const [editId, setEditId] = useState<number | null>(null);

  const { data: plates = [] } = useQuery({ queryKey: ["whitelist"], queryFn: () => getWhitelist().then((r) => r.data) });

  const addMut = useMutation({
    mutationFn: (data: any) => editId ? updatePlate(editId, data) : addPlate(data),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["whitelist"] }); setShowForm(false); setForm(EMPTY_FORM); setEditId(null); toast.success(editId ? "Dikemaskini" : "Plat ditambah"); },
    onError: (e: any) => toast.error(e.response?.data?.detail || "Ralat"),
  });

  const delMut = useMutation({
    mutationFn: (id: number) => deletePlate(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["whitelist"] }); toast.success("Dipadam"); },
  });

  const onEdit = (p: any) => { setForm({ plate_number: p.plate_number, owner_name: p.owner_name || "", vehicle_make: p.vehicle_make || "", vehicle_model: p.vehicle_model || "", vehicle_color: p.vehicle_color || "", notes: p.notes || "" }); setEditId(p.id); setShowForm(true); };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-bold">Senarai Putih Plat</h1>
        <button onClick={() => { setShowForm(true); setEditId(null); setForm(EMPTY_FORM); }} className="flex items-center gap-2 bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700">
          <Plus size={18} /> Tambah Plat
        </button>
      </div>

      {showForm && (
        <div className="bg-white border rounded-xl p-5 shadow-sm">
          <h2 className="font-semibold mb-4">{editId ? "Kemaskini" : "Tambah"} Plat</h2>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {Object.keys(EMPTY_FORM).map((k) => (
              <div key={k}>
                <label className="text-xs text-gray-500 uppercase">{k.replace("_", " ")}</label>
                <input value={(form as any)[k]} onChange={(e) => setForm({ ...form, [k]: e.target.value })}
                  className="w-full border rounded-lg px-3 py-2 text-sm mt-1 focus:outline-none focus:ring-2 focus:ring-blue-300"
                  placeholder={k === "plate_number" ? "cth: WXY1234" : ""}
                />
              </div>
            ))}
          </div>
          <div className="flex gap-3 mt-4">
            <button onClick={() => addMut.mutate(form)} className="bg-blue-600 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-700">
              {addMut.isPending ? "Menyimpan..." : "Simpan"}
            </button>
            <button onClick={() => { setShowForm(false); setEditId(null); }} className="border px-4 py-2 rounded-lg text-sm">Batal</button>
          </div>
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-gray-50 text-gray-500 text-xs uppercase">
            <tr>
              <th className="px-4 py-3 text-left">No. Plat</th>
              <th className="px-4 py-3 text-left">Nama Pemilik</th>
              <th className="px-4 py-3 text-left">Kenderaan</th>
              <th className="px-4 py-3 text-left">Warna</th>
              <th className="px-4 py-3 text-left">Status</th>
              <th className="px-4 py-3 text-left">Tindakan</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {plates.map((p: any) => (
              <tr key={p.id} className="hover:bg-gray-50">
                <td className="px-4 py-3 font-mono font-bold text-blue-700">{p.plate_number}</td>
                <td className="px-4 py-3">{p.owner_name || "—"}</td>
                <td className="px-4 py-3">{[p.vehicle_make, p.vehicle_model].filter(Boolean).join(" ") || "—"}</td>
                <td className="px-4 py-3">{p.vehicle_color || "—"}</td>
                <td className="px-4 py-3">{p.is_active ? <CheckCircle size={16} className="text-green-500" /> : <XCircle size={16} className="text-red-400" />}</td>
                <td className="px-4 py-3 flex gap-2">
                  <button onClick={() => onEdit(p)} className="text-blue-500 hover:text-blue-700"><Edit2 size={16} /></button>
                  <button onClick={() => { if (confirm("Padam plat ini?")) delMut.mutate(p.id); }} className="text-red-400 hover:text-red-600"><Trash2 size={16} /></button>
                </td>
              </tr>
            ))}
            {plates.length === 0 && (
              <tr><td colSpan={6} className="px-4 py-8 text-center text-gray-400">Tiada plat dalam senarai putih</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
