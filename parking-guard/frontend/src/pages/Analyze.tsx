import React, { useRef, useState } from "react";
import { Upload, Camera, ScanLine } from "lucide-react";
import Webcam from "react-webcam";
import toast from "react-hot-toast";
import { analyzeImage } from "../utils/api";

export default function Analyze() {
  const [mode, setMode] = useState<"upload" | "camera">("upload");
  const [result, setResult] = useState<any>(null);
  const [loading, setLoading] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);
  const fileRef = useRef<HTMLInputElement>(null);
  const webcamRef = useRef<Webcam>(null);

  const analyze = async (file: File) => {
    setLoading(true);
    try {
      const res = await analyzeImage(file, "manual");
      setResult(res.data);
      toast.success("Analisis selesai");
    } catch (e: any) {
      toast.error(e.response?.data?.detail || "Ralat analisis");
    } finally {
      setLoading(false);
    }
  };

  const onFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setPreview(URL.createObjectURL(file));
    await analyze(file);
  };

  const captureAndAnalyze = async () => {
    const shot = webcamRef.current?.getScreenshot();
    if (!shot) return;
    setPreview(shot);
    const blob = await fetch(shot).then((r) => r.blob());
    await analyze(new File([blob], "capture.jpg", { type: "image/jpeg" }));
  };

  return (
    <div className="p-6 space-y-6">
      <h1 className="text-2xl font-bold">Analisis Imej / Kamera</h1>

      <div className="flex gap-3">
        <button onClick={() => setMode("upload")} className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm ${mode === "upload" ? "bg-blue-600 text-white" : "border"}`}><Upload size={16} /> Muat Naik</button>
        <button onClick={() => setMode("camera")} className={`flex items-center gap-2 px-4 py-2 rounded-lg text-sm ${mode === "camera" ? "bg-blue-600 text-white" : "border"}`}><Camera size={16} /> Kamera Langsung</button>
      </div>

      <div className="grid md:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl border shadow-sm p-4">
          {mode === "upload" ? (
            <div>
              <div onClick={() => fileRef.current?.click()}
                className="border-2 border-dashed border-gray-300 rounded-xl p-8 text-center cursor-pointer hover:border-blue-400">
                {preview ? <img src={preview} alt="preview" className="max-h-64 mx-auto rounded-lg" /> : (
                  <><Upload size={32} className="mx-auto text-gray-400 mb-2" /><p className="text-gray-500 text-sm">Klik untuk pilih foto kenderaan</p></>
                )}
              </div>
              <input ref={fileRef} type="file" accept="image/*" className="hidden" onChange={onFileChange} />
            </div>
          ) : (
            <div>
              <Webcam ref={webcamRef} screenshotFormat="image/jpeg" className="w-full rounded-xl" videoConstraints={{ facingMode: "environment" }} />
              <button onClick={captureAndAnalyze} disabled={loading}
                className="mt-3 w-full bg-blue-600 text-white py-2 rounded-lg flex items-center justify-center gap-2 hover:bg-blue-700 disabled:opacity-50">
                <ScanLine size={18} /> {loading ? "Menganalisis..." : "Imbas Sekarang"}
              </button>
            </div>
          )}
        </div>

        <div className="bg-white rounded-xl border shadow-sm p-4">
          <h2 className="font-semibold mb-4">Keputusan Analisis</h2>
          {loading && <div className="text-center py-8 text-gray-400">Memproses AI...</div>}
          {result && !loading && (
            <div className="space-y-3">
              <ResultRow label="No. Plat" value={result.plate_number} highlight />
              <ResultRow label="Keyakinan Plat" value={result.plate_confidence ? `${(result.plate_confidence * 100).toFixed(1)}%` : "—"} />
              <ResultRow label="Jenis Kenderaan" value={result.vehicle_model} />
              <ResultRow label="Warna" value={result.vehicle_color} />
              <ResultRow label="Muka Dikenal" value={result.face_name || (result.face_recognized ? "Ya" : "Tidak")} />
              <div className={`mt-4 p-3 rounded-lg text-center font-semibold ${result.is_whitelisted ? "bg-green-100 text-green-700" : result.alert_triggered ? "bg-red-100 text-red-700" : "bg-gray-100 text-gray-600"}`}>
                {result.is_whitelisted ? "✅ Kenderaan Dibenarkan" : result.alert_triggered ? "🚨 AMARAN — Kenderaan Tidak Dibenarkan" : result.owner_face_detected ? "✅ Muka Tuan Rumah Dikesan" : "⚠️ Kenderaan Tidak Dikenal"}
              </div>
            </div>
          )}
          {!result && !loading && <div className="text-center py-8 text-gray-400">Muat naik atau imbas gambar untuk analisis</div>}
        </div>
      </div>
    </div>
  );
}

function ResultRow({ label, value, highlight }: { label: string; value: any; highlight?: boolean }) {
  return (
    <div className="flex justify-between items-center py-2 border-b">
      <span className="text-sm text-gray-500">{label}</span>
      <span className={`text-sm font-medium ${highlight ? "font-mono text-blue-700 text-base" : ""}`}>{value || "—"}</span>
    </div>
  );
}
