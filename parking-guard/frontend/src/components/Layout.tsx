import React from "react";
import { NavLink, Outlet, useNavigate } from "react-router-dom";
import { LayoutDashboard, ListChecks, UserCheck, ScanLine, LogOut, ShieldCheck } from "lucide-react";

const nav_items = [
  { to: "/", label: "Dashboard", icon: <LayoutDashboard size={18} /> },
  { to: "/whitelist", label: "Senarai Putih", icon: <ListChecks size={18} /> },
  { to: "/faces", label: "Profil Muka", icon: <UserCheck size={18} /> },
  { to: "/analyze", label: "Analisis", icon: <ScanLine size={18} /> },
];

export default function Layout() {
  const navigate = useNavigate();
  const logout = () => { localStorage.removeItem("token"); navigate("/login"); };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside className="w-60 bg-slate-900 text-white flex flex-col">
        <div className="p-5 border-b border-slate-700 flex items-center gap-3">
          <ShieldCheck size={24} className="text-blue-400" />
          <div>
            <div className="font-bold">ParkingGuard</div>
            <div className="text-xs text-slate-400">v1.0.0</div>
          </div>
        </div>
        <nav className="flex-1 p-3 space-y-1">
          {nav_items.map((item) => (
            <NavLink key={item.to} to={item.to} end={item.to === "/"}
              className={({ isActive }) => `flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm transition ${isActive ? "bg-blue-600 text-white" : "text-slate-300 hover:bg-slate-800"}`}>
              {item.icon}{item.label}
            </NavLink>
          ))}
        </nav>
        <div className="p-3 border-t border-slate-700">
          <button onClick={logout} className="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm text-slate-300 hover:bg-slate-800 w-full">
            <LogOut size={18} /> Log Keluar
          </button>
        </div>
      </aside>
      {/* Main */}
      <main className="flex-1 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
