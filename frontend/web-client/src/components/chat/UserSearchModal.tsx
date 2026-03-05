import { useState } from "react";
import { userService } from "../../services/user";
import type { User } from "../../types";

interface UserSearchModalProps {
  open: boolean;
  onClose: () => void;
  onSelectUser: (user: User) => void;
  title?: string;
}

export default function UserSearchModal({
  open,
  onClose,
  onSelectUser,
  title = "Search Users",
}: UserSearchModalProps) {
  const [query, setQuery] = useState("");
  const [result, setResult] = useState<User | null>(null);
  const [searching, setSearching] = useState(false);
  const [error, setError] = useState("");

  if (!open) return null;

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;
    setSearching(true);
    setError("");
    setResult(null);
    try {
      const res = await userService.searchByUsername(query.trim());
      setResult(res.data);
    } catch {
      setError("User not found");
    }
    setSearching(false);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-full max-w-md rounded-xl bg-white p-6 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
        <form onSubmit={handleSearch} className="mt-4 flex gap-2">
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Search by username..."
            className="flex-1 rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            autoFocus
          />
          <button
            type="submit"
            disabled={searching || !query.trim()}
            className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
          >
            {searching ? "..." : "Search"}
          </button>
        </form>
        {error && <p className="mt-3 text-sm text-red-500">{error}</p>}
        {result && (
          <div className="mt-4 flex items-center justify-between rounded-lg border border-gray-200 p-3">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 text-sm font-semibold text-primary-700">
                {result.fullName?.charAt(0).toUpperCase()}
              </div>
              <div>
                <p className="text-sm font-medium text-gray-900">
                  {result.fullName}
                </p>
                <p className="text-xs text-gray-500">
                  @{result.username} · {result.role}
                </p>
              </div>
            </div>
            <button
              onClick={() => {
                onSelectUser(result);
                onClose();
              }}
              className="rounded-lg bg-primary-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-primary-700"
            >
              Select
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
