import React from "react";
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "react-hot-toast";
import Layout from "./components/Layout";
import Dashboard from "./pages/Dashboard";
import Whitelist from "./pages/Whitelist";
import FaceProfiles from "./pages/FaceProfiles";
import Analyze from "./pages/Analyze";
import Login from "./pages/Login";

const qc = new QueryClient();

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  return localStorage.getItem("token") ? <>{children}</> : <Navigate to="/login" replace />;
}

export default function App() {
  return (
    <QueryClientProvider client={qc}>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
            <Route index element={<Dashboard />} />
            <Route path="whitelist" element={<Whitelist />} />
            <Route path="faces" element={<FaceProfiles />} />
            <Route path="analyze" element={<Analyze />} />
          </Route>
        </Routes>
      </BrowserRouter>
      <Toaster position="top-right" />
    </QueryClientProvider>
  );
}
