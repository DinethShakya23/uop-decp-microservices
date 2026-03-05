import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import type { UserRegistrationRequest } from "../types";
import ErrorAlert from "../components/common/ErrorAlert";

export default function LoginPage() {
  const navigate = useNavigate();
  const { login, register } = useAuth();
  const [isRegister, setIsRegister] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Login fields
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  // Register fields
  const [regUsername, setRegUsername] = useState("");
  const [regEmail, setRegEmail] = useState("");
  const [regPassword, setRegPassword] = useState("");
  const [regFullName, setRegFullName] = useState("");
  const [regRole, setRegRole] = useState<"STUDENT" | "ALUMNI">("STUDENT");

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!username.trim() || !password) return;
    setLoading(true);
    setError("");
    try {
      await login({ username: username.trim(), password });
      navigate("/", { replace: true });
    } catch (err: any) {
      setError(
        err.response?.data?.message ||
          err.response?.data ||
          "Login failed. Check your credentials.",
      );
    }
    setLoading(false);
  };

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    if (
      !regUsername.trim() ||
      !regEmail.trim() ||
      !regPassword ||
      !regFullName.trim()
    )
      return;
    setLoading(true);
    setError("");
    try {
      const data: UserRegistrationRequest = {
        username: regUsername.trim(),
        email: regEmail.trim(),
        password: regPassword,
        fullName: regFullName.trim(),
        role: regRole,
      };
      await register(data);
      // Auto-login after registration
      await login({ username: regUsername.trim(), password: regPassword });
      navigate("/", { replace: true });
    } catch (err: any) {
      setError(
        err.response?.data?.message ||
          err.response?.data ||
          "Registration failed.",
      );
    }
    setLoading(false);
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50 px-4">
      <div className="w-full max-w-md">
        {/* Logo */}
        <div className="mb-8 text-center">
          <div className="mx-auto flex h-14 w-14 items-center justify-center rounded-xl bg-primary-600 text-2xl font-bold text-white shadow-lg">
            D
          </div>
          <h1 className="mt-4 text-2xl font-bold text-gray-900">
            {isRegister ? "Create Account" : "Welcome Back"}
          </h1>
          <p className="mt-1 text-sm text-gray-500">
            {isRegister
              ? "Join the Department Engagement & Career Platform"
              : "Sign in to DECP"}
          </p>
        </div>

        {/* Card */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <ErrorAlert message={error} onClose={() => setError("")} />

          {!isRegister ? (
            /* Login Form */
            <form onSubmit={handleLogin} className="space-y-4">
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Username
                </label>
                <input
                  type="text"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="Enter your username"
                  required
                  autoFocus
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Password
                </label>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="Enter your password"
                  required
                />
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full rounded-lg bg-primary-600 py-2.5 text-sm font-semibold text-white hover:bg-primary-700 disabled:opacity-50"
              >
                {loading ? "Signing in..." : "Sign In"}
              </button>
            </form>
          ) : (
            /* Register Form */
            <form onSubmit={handleRegister} className="space-y-4">
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Full Name
                </label>
                <input
                  type="text"
                  value={regFullName}
                  onChange={(e) => setRegFullName(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="John Doe"
                  required
                  autoFocus
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Username
                </label>
                <input
                  type="text"
                  value={regUsername}
                  onChange={(e) => setRegUsername(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="johndoe"
                  required
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Email
                </label>
                <input
                  type="email"
                  value={regEmail}
                  onChange={(e) => setRegEmail(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="john@example.com"
                  required
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Password
                </label>
                <input
                  type="password"
                  value={regPassword}
                  onChange={(e) => setRegPassword(e.target.value)}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="Min. 6 characters"
                  required
                  minLength={6}
                />
              </div>
              <div>
                <label className="mb-1 block text-sm font-medium text-gray-700">
                  Role
                </label>
                <select
                  value={regRole}
                  onChange={(e) =>
                    setRegRole(e.target.value as "STUDENT" | "ALUMNI")
                  }
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                >
                  <option value="STUDENT">Student</option>
                  <option value="ALUMNI">Alumni</option>
                </select>
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full rounded-lg bg-primary-600 py-2.5 text-sm font-semibold text-white hover:bg-primary-700 disabled:opacity-50"
              >
                {loading ? "Creating Account..." : "Create Account"}
              </button>
            </form>
          )}

          {/* Toggle */}
          <p className="mt-4 text-center text-sm text-gray-500">
            {isRegister ? "Already have an account?" : "Don't have an account?"}{" "}
            <button
              onClick={() => {
                setIsRegister(!isRegister);
                setError("");
              }}
              className="font-medium text-primary-600 hover:text-primary-700"
            >
              {isRegister ? "Sign In" : "Create Account"}
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}
