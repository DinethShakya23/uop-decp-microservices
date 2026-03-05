import { useState } from "react";
import { useAuth } from "../context/AuthContext";
import { useNavigate } from "react-router-dom";

export default function SettingsPage() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [bio, setBio] = useState(user?.bio || "");
  const [saved, setSaved] = useState(false);

  const handleSaveProfile = (e: React.FormEvent) => {
    e.preventDefault();
    // Would call user update API if available
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  return (
    <div className="mx-auto max-w-2xl px-4 py-6">
      <h1 className="mb-6 text-2xl font-bold text-gray-900">Settings</h1>

      <div className="space-y-6">
        {/* Profile Settings */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900">
            Profile Settings
          </h2>
          <form onSubmit={handleSaveProfile} className="mt-4 space-y-4">
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                Full Name
              </label>
              <input
                type="text"
                defaultValue={user?.fullName}
                disabled
                className="w-full rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-sm text-gray-500"
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                Username
              </label>
              <input
                type="text"
                defaultValue={user?.username}
                disabled
                className="w-full rounded-lg border border-gray-200 bg-gray-50 px-3 py-2.5 text-sm text-gray-500"
              />
            </div>
            <div>
              <label className="mb-1 block text-sm font-medium text-gray-700">
                Bio
              </label>
              <textarea
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={3}
                className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                placeholder="Tell us about yourself..."
              />
            </div>
            <button
              type="submit"
              className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
            >
              Save Changes
            </button>
            {saved && (
              <span className="ml-3 text-sm text-green-600">Saved!</span>
            )}
          </form>
        </div>

        {/* Notification Preferences */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900">
            Notification Preferences
          </h2>
          <div className="mt-4 space-y-3">
            {[
              "Post likes & comments",
              "Job applications",
              "Event RSVPs",
              "Mentorship requests",
              "System notifications",
            ].map((label) => (
              <label key={label} className="flex items-center justify-between">
                <span className="text-sm text-gray-700">{label}</span>
                <input
                  type="checkbox"
                  defaultChecked
                  className="h-4 w-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500"
                />
              </label>
            ))}
          </div>
        </div>

        {/* Account */}
        <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-gray-900">Account</h2>
          <div className="mt-4 space-y-3">
            <div className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Email</p>
                <p className="text-sm text-gray-500">{user?.email}</p>
              </div>
            </div>
            <div className="flex items-center justify-between rounded-lg bg-gray-50 p-3">
              <div>
                <p className="text-sm font-medium text-gray-700">Role</p>
                <p className="text-sm text-gray-500">{user?.role}</p>
              </div>
            </div>
          </div>
          <div className="mt-6 border-t border-gray-200 pt-4">
            <button
              onClick={handleLogout}
              className="rounded-lg border border-red-300 px-4 py-2 text-sm font-medium text-red-600 hover:bg-red-50"
            >
              Sign Out
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
