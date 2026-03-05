import axios from "axios";
import { getToken, clearAuth } from "../utils/localStorage";

const api = axios.create({
  baseURL: "http://localhost:8080",
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (res) => res,
  (error) => {
    if (error.response?.status === 401) {
      clearAuth();
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);

export default api;
