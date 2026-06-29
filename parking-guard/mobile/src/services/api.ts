import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

const BASE_URL_KEY = "pg_base_url";
const TOKEN_KEY = "pg_token";

export const getBaseUrl = async () => (await AsyncStorage.getItem(BASE_URL_KEY)) || "http://192.168.1.100:8000";
export const setBaseUrl = (url: string) => AsyncStorage.setItem(BASE_URL_KEY, url);
export const getToken = () => AsyncStorage.getItem(TOKEN_KEY);
export const setToken = (t: string) => AsyncStorage.setItem(TOKEN_KEY, t);
export const clearToken = () => AsyncStorage.removeItem(TOKEN_KEY);

export const createApi = async () => {
  const baseURL = await getBaseUrl();
  const token = await getToken();
  return axios.create({
    baseURL,
    headers: token ? { Authorization: `Bearer ${token}` } : {},
    timeout: 15000,
  });
};

export const login = async (username: string, password: string) => {
  const api = await createApi();
  const params = new URLSearchParams({ username, password });
  const res = await api.post("/api/auth/login", params);
  await setToken(res.data.access_token);
  return res.data;
};

export const getStats = async () => {
  const api = await createApi();
  return (await api.get("/api/events/stats")).data;
};

export const getEvents = async (limit = 20) => {
  const api = await createApi();
  return (await api.get(`/api/events/?limit=${limit}`)).data;
};

export const getWhitelist = async () => {
  const api = await createApi();
  return (await api.get("/api/whitelist/")).data;
};

export const addPlate = async (data: any) => {
  const api = await createApi();
  return (await api.post("/api/whitelist/", data)).data;
};

export const deletePlate = async (id: number) => {
  const api = await createApi();
  return (await api.delete(`/api/whitelist/${id}`)).data;
};

export const analyzeImageMobile = async (uri: string, zone = "mobile") => {
  const api = await createApi();
  const fd = new FormData() as any;
  fd.append("file", { uri, name: "capture.jpg", type: "image/jpeg" });
  fd.append("zone", zone);
  return (await api.post("/api/events/analyze", fd, { headers: { "Content-Type": "multipart/form-data" } })).data;
};
