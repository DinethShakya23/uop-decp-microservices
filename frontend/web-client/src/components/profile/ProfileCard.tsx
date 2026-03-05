import type { User } from "../../types";

interface ProfileCardProps {
  user: User;
  onMessage?: () => void;
}

export default function ProfileCard({ user, onMessage }: ProfileCardProps) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-6 shadow-sm">
      <div className="flex items-center gap-4">
        <div className="flex h-16 w-16 items-center justify-center rounded-full bg-primary-100 text-2xl font-bold text-primary-700">
          {user.profilePictureUrl ? (
            <img
              src={user.profilePictureUrl}
              alt=""
              className="h-16 w-16 rounded-full object-cover"
            />
          ) : (
            user.fullName?.charAt(0).toUpperCase()
          )}
        </div>
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">
            {user.fullName}
          </h3>
          <p className="text-sm text-gray-500">@{user.username}</p>
          <span className="mt-1 inline-block rounded-full bg-primary-50 px-2.5 py-0.5 text-xs font-medium text-primary-700">
            {user.role}
          </span>
        </div>
      </div>
      {user.bio && <p className="mt-4 text-sm text-gray-600">{user.bio}</p>}
      {onMessage && (
        <button
          onClick={onMessage}
          className="mt-4 w-full rounded-lg border border-primary-600 px-4 py-2 text-sm font-medium text-primary-600 hover:bg-primary-50"
        >
          Send Message
        </button>
      )}
    </div>
  );
}
