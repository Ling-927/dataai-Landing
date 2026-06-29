import React, { useRef, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { UserPlus, Trash2, Crown } from "lucide-react";
import toast from "react-hot-toast";
import { getFaces, addFace, deleteFace } from "../utils/api";

export default function FaceProfiles() {
  const qc = useQueryClient();
  const fileRef = useRef<HTMLInputElement>(null);
  const [name, setName] = useState("");
  const [isOwner, setIsOwner] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);
  const [file, setFile] = useState<File | null>(null);

  const { data: faces = [] } = useQuery({ queryKey: ["faces"], queryFn: () => getFaces().then((r) => r.data) });

  const addMut = useMutation({
    mutationFn: () => addFace(name, isOwner, file!),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["faces"] }); setName(""); setFile(null); setPreview(null); toast.success("Profil muka ditambah"); },
    onError: (e: any) => toast.error(e.response?.data?.detail || "Muka tidak dapat dikesan"),
  });

  const delMut = useMutation({
    mutationFn: (id: number) => deleteFace(id),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["faces"] }); toast.success("Dipadam"); },
  });

  const onFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const f = e.target.files?.[0];
    if (!f) return;
    setFile(f);
    setPreview(URL.createObjectURL(f));
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Profil Muka</h1>

      <div className="bg-white rounded-xl shadow-sm border p-5">
        <h2 className="font-semibold mb-4 flex items-center gap-2"><UserPlus size={18} /> Daftar Muka Baru</h2>
        <div className="grid md:grid-cols-2 gap-4">
          <div className="space-y-3">
            <div>
              <label className="text-xs text-gray-500 uppercase">Nama</label>
              <input value={name} onChange={(e) => setName(e.target.value)} className="w-full border rounded-lg px-3 py-2 mt-1 text-sm focus:outline-none focus:ring-2 focus:ring-blue-300" placeholder="cth: Tuan Rumah / Ahmad" />
            </div>
            <div className="flex items-center gap-2">
              <input type="checkbox" id="isOwner" checked={isOwner} onChange={(e) => setIsOwner(e.target.checked)} className="w-4 h-4" />
              <label htmlFor="isOwner" className="text-sm flex items-center gap-1"><Crown size={14} className="text-yellow-500" /> Ini adalah tuan rumah (bypass amaran)</label>
            </div>
            <button onClick={() => fileRef.current?.click()} className="w-full border-2 border-dashed border-gray-300 rounded-lg p-4 text-sm text-gray-500 hover:border-blue-400">
              {file ? file.name : "Klik untuk muat naik foto muka yang jelas"}
            </button>
            <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={onFileChange} />
            <button onClick={() => addMut.mutate()} disabled={!name || !file || addMut.isPending}
              className="w-full bg-blue-600 text-white py-2 rounded-lg text-sm hover:bg-blue-700 disabled:opacity-50">
              {addMut.isPending ? "Memproses..." : "Tambah Profil"}
            </button>
          </div>
          {preview && (
            <div className="flex items-center justify-center">
              <img src={preview} alt="preview" className="max-h-48 rounded-xl object-cover border" />
            </div>
          )}
        </div>
      </div>

      <div className="grid md:grid-cols-3 gap-4">
        {faces.map((f: any) => (
          <div key={f.id} className="bg-white rounded-xl border shadow-sm p-4 flex flex-col gap-3">
            {f.photo_path ? (
              <img src={`/uploads/${f.photo_path.split("/").pop()}`} alt={f.name} className="w-full h-40 object-cover rounded-lg" />
            ) : (
              <div className="w-full h-40 bg-gray-100 rounded-lg flex items-center justify-center text-5xl">👤</div>
            )}
            <div className="flex items-center justify-between">
              <div>
                <div className="font-semibold">{f.name}</div>
                {f.is_owner && <span className="text-xs bg-yellow-100 text-yellow-700 px-2 py-0.5 rounded-full flex items-center gap-1 w-fit mt-1"><Crown size={10} /> Tuan Rumah</span>}
              </div>
              <button onClick={() => { if (confirm("Padam profil?")) delMut.mutate(f.id); }} className="text-red-400 hover:text-red-600"><Trash2 size={16} /></button>
            </div>
          </div>
        ))}
        {faces.length === 0 && (
          <div className="col-span-3 text-center py-12 text-gray-400">Tiada profil muka didaftarkan</div>
        )}
      </div>
    </div>
  );
}
