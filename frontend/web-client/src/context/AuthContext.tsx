import {
  createContext,
  useContext,
  useState,
  useEffect,
  useCallback,
  type ReactNode,
} from "react";
import type { User, AuthRequest, UserRegistrationRequest } from "../types";
import { authService } from "../services/auth";
import {
  getToken,
  setToken,
  clearAuth,
  getStoredUser,
  setStoredUser,
} from "../utils/localStorage";

interface AuthContextType {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (data: AuthRequest) => Promise<void>;
  register: (data: UserRegistrationRequest) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [token, setTokenState] = useState<string | null>(getToken());
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const storedToken = getToken();
    const storedUser = getStoredUser();
    if (storedToken && storedUser) {
      try {
        setUser(JSON.parse(storedUser));
        setTokenState(storedToken);
      } catch {
        clearAuth();
      }
    }
    setLoading(false);
  }, []);

  const login = useCallback(async (data: AuthRequest) => {
    const res = await authService.login(data);
    const { token: jwt, user: userData } = res.data;
    setToken(jwt);
    setStoredUser(JSON.stringify(userData));
    setTokenState(jwt);
    setUser(userData);
  }, []);

  const register = useCallback(async (data: UserRegistrationRequest) => {
    await authService.register(data);
  }, []);

  const logout = useCallback(() => {
    clearAuth();
    setTokenState(null);
    setUser(null);
  }, []);

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        isAuthenticated: !!token && !!user,
        loading,
        login,
        register,
        logout,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthContextType {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error("useAuth must be used within AuthProvider");
  return ctx;
}
