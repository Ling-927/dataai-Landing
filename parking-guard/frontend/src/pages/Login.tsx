import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { ShieldCheck } from "lucide-react";
import toast from "react-hot-toast";
import { login } from "../utils/api";

export default function Login() {
  const nav = useNavigate();
  const [form, setForm] = useState({ username: "", password: "" });
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await login(form.username, form.password);
      localStorage.setItem("token", res.data.access_token);
      toast.success("Log masuk berjaya");
      nav("/");
    } catch {
      toast.error("Nama pengguna atau kata laluan salah");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-900 to-slate-800 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl p-8 w-full max-w-sm">
        <div className="text-center mb-8">
          <ShieldCheck size={48} className="mx-auto text-blue-600 mb-3" />
          <h1 className="text-2xl font-bold text-gray-900">I Defender</h1>
          <p className="text-gray-500 text-sm mt-1">Sistem Pengawasan Kenderaan</p>
        </div>
        <form onSubmit={onSubmit} className="space-y-4">
          <div>
            <label className="text-sm text-gray-600">Nama Pengguna</label>
            <input value={form.username} onChange={(e) => setForm({ ...form, username: e.target.value })}
              className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-400" required />
          </div>
          <div>
            <label className="text-sm text-gray-600">Kata Laluan</label>
            <input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })}
              className="w-full border rounded-lg px-3 py-2 mt-1 focus:outline-none focus:ring-2 focus:ring-blue-400" required />
          </div>
          <button type="submit" disabled={loading}
            className="w-full bg-blue-600 text-white py-2.5 rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50 mt-2">
            {loading ? "Log masuk..." : "Log Masuk"}
          </button>
        </form>
      </div>
    </div>
  );
}
