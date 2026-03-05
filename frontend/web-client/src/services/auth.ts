import api from "./api";
import type {
  AuthRequest,
  AuthResponse,
  UserRegistrationRequest,
  User,
} from "../types";

export const authService = {
  login: (data: AuthRequest) => api.post<AuthResponse>("/api/auth/login", data),

  register: (data: UserRegistrationRequest) =>
    api.post<User>("/api/users/register", data),

  validate: (token: string) =>
    api.get("/api/auth/validate", { params: { token } }),
};
