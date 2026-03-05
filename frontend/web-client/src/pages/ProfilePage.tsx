import { useState } from "react";
import { useAuth } from "../context/AuthContext";

export default function ProfilePage() {
  const { user } = useAuth();
  const [editing, setEditing] = useState(false);
  const [bio, setBio] = useState(user?.bio || "");

  if (!user) return null;

  return (
    <div className="mx-auto max-w-3xl px-4 py-6">
      <div className="rounded-xl border border-gray-200 bg-white shadow-sm">
        {/* Header */}
        <div className="relative h-32 rounded-t-xl bg-gradient-to-r from-primary-500 to-primary-700">
          <div className="absolute -bottom-10 left-6 flex h-20 w-20 items-center justify-center rounded-full border-4 border-white bg-primary-100 text-3xl font-bold text-primary-700 shadow-md">
            {user.profilePictureUrl ? (
              <img
                src={user.profilePictureUrl}
                alt=""
                className="h-full w-full rounded-full object-cover"
              />
            ) : (
              user.fullName?.charAt(0).toUpperCase()
            )}
          </div>
        </div>

        {/* Info */}
        <div className="px-6 pb-6 pt-14">
          <div className="flex items-start justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">
                {user.fullName}
              </h1>
              <p className="text-gray-500">@{user.username}</p>
              <span className="mt-2 inline-block rounded-full bg-primary-50 px-3 py-1 text-xs font-medium text-primary-700">
                {user.role}
              </span>
            </div>
            <button
              onClick={() => setEditing(!editing)}
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              {editing ? "Cancel" : "Edit Profile"}
            </button>
          </div>

          {/* Bio */}
          <div className="mt-6">
            <h3 className="text-sm font-semibold text-gray-700">About</h3>
            {editing ? (
              <div className="mt-2">
                <textarea
                  value={bio}
                  onChange={(e) => setBio(e.target.value)}
                  rows={3}
                  className="w-full rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
                  placeholder="Tell us about yourself..."
                />
                <button
                  onClick={() => setEditing(false)}
                  className="mt-2 rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
                >
                  Save
                </button>
              </div>
            ) : (
              <p className="mt-1 text-sm text-gray-600">
                {user.bio || "No bio yet"}
              </p>
            )}
          </div>

          {/* Details */}
          <div className="mt-6 grid grid-cols-2 gap-4">
            <div className="rounded-lg bg-gray-50 p-4">
              <p className="text-xs font-medium text-gray-500">Email</p>
              <p className="mt-1 text-sm text-gray-900">{user.email}</p>
            </div>
            <div className="rounded-lg bg-gray-50 p-4">
              <p className="text-xs font-medium text-gray-500">Role</p>
              <p className="mt-1 text-sm text-gray-900">{user.role}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
