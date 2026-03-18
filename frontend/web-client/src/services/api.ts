import axios from "axios";
import { getToken, clearAuth, getStoredUser } from "../utils/localStorage";

const apiBaseUrl =
  import.meta.env.VITE_API_BASE_URL ||
  `${window.location.protocol}//${window.location.hostname}:8080`;

const api = axios.create({
  baseURL: apiBaseUrl,
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }

  // Add user headers from stored user
  const storedUser = getStoredUser();
  if (storedUser) {
    try {
      const user = JSON.parse(storedUser);
      if (user.id !== undefined && user.id !== null) {
        config.headers["X-User-Id"] = String(user.id);
      }
      if (user.role) {
        config.headers["X-User-Role"] = user.role;
      }
      if (user.fullName) {
        config.headers["X-User-Name"] = user.fullName;
      }
    } catch (e) {
      console.error("Failed to parse stored user:", e);
    }
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
