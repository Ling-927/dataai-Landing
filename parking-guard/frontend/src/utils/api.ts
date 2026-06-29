import axios from "axios";

const BASE_URL = process.env.REACT_APP_API_URL || "http://localhost:8000";

export const api = axios.create({ baseURL: BASE_URL });

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem("token");
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);

// Auth
export const login = (username: string, password: string) =>
  api.post("/api/auth/login", new URLSearchParams({ username, password }));
export const getMe = () => api.get("/api/auth/me");

// Whitelist
export const getWhitelist = () => api.get("/api/whitelist/");
export const addPlate = (data: any) => api.post("/api/whitelist/", data);
export const updatePlate = (id: number, data: any) => api.put(`/api/whitelist/${id}`, data);
export const deletePlate = (id: number) => api.delete(`/api/whitelist/${id}`);
export const checkPlate = (plate: string) => api.get(`/api/whitelist/check/${plate}`);

// Events
export const getEvents = (params?: any) => api.get("/api/events/", { params });
export const getStats = () => api.get("/api/events/stats");
export const analyzeImage = (file: File, zone?: string) => {
  const fd = new FormData();
  fd.append("file", file);
  if (zone) fd.append("zone", zone);
  return api.post("/api/events/analyze", fd);
};
export const acknowledgeEvent = (id: number) => api.put(`/api/events/${id}/acknowledge`);

// Faces
export const getFaces = () => api.get("/api/faces/");
export const addFace = (name: string, isOwner: boolean, file: File) => {
  const fd = new FormData();
  fd.append("name", name);
  fd.append("is_owner", String(isOwner));
  fd.append("file", file);
  return api.post("/api/faces/", fd);
};
export const deleteFace = (id: number) => api.delete(`/api/faces/${id}`);
