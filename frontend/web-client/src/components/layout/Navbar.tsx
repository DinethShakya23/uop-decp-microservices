import { Link, useLocation, useNavigate } from "react-router-dom";
import { useAuth } from "../../context/AuthContext";
import { useNotifications } from "../../context/NotificationContext";

export default function Navbar() {
  const { user, logout, isAuthenticated } = useAuth();
  const { unreadCount } = useNotifications();
  const location = useLocation();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  const navLink = (to: string, label: string) => (
    <Link
      to={to}
      className={`rounded-lg px-3 py-2 text-sm font-medium transition-colors ${
        location.pathname === to
          ? "bg-primary-50 text-primary-700"
          : "text-gray-600 hover:bg-gray-100 hover:text-gray-900"
      }`}
    >
      {label}
    </Link>
  );

  if (!isAuthenticated) return null;

  return (
    <header className="sticky top-0 z-40 border-b border-gray-200 bg-white/95 backdrop-blur">
      <div className="mx-auto flex max-w-7xl items-center justify-between px-4 py-3">
        {/* Logo */}
        <Link to="/" className="flex items-center gap-2">
          <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary-600 text-sm font-bold text-white">
            D
          </div>
          <span className="text-lg font-bold text-gray-900">DECP</span>
        </Link>

        {/* Navigation */}
        <nav className="hidden items-center gap-1 md:flex">
          {navLink("/", "Feed")}
          {navLink("/jobs", "Jobs")}
          {navLink("/events", "Events")}
          {navLink("/research", "Research")}
          {navLink("/chat", "Chat")}
          {navLink("/mentorship", "Mentorship")}
          {user?.role === "ADMIN" && navLink("/admin", "Admin")}
        </nav>

        {/* Right side */}
        <div className="flex items-center gap-3">
          {/* Notifications */}
          <Link
            to="/notifications"
            className="relative rounded-lg p-2 text-gray-500 hover:bg-gray-100 hover:text-gray-700"
          >
            <svg
              className="h-5 w-5"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={2}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
              />
            </svg>
            {unreadCount > 0 && (
              <span className="absolute -right-0.5 -top-0.5 flex h-5 w-5 items-center justify-center rounded-full bg-red-500 text-[10px] font-bold text-white">
                {unreadCount > 99 ? "99+" : unreadCount}
              </span>
            )}
          </Link>

          {/* User menu */}
          <div className="flex items-center gap-2">
            <Link
              to="/profile"
              className="flex h-8 w-8 items-center justify-center rounded-full bg-primary-100 text-sm font-semibold text-primary-700"
            >
              {user?.fullName?.charAt(0).toUpperCase() || "U"}
            </Link>
            <div className="hidden flex-col md:flex">
              <span className="text-sm font-medium text-gray-900">
                {user?.fullName}
              </span>
              <span className="text-xs text-gray-500">{user?.role}</span>
            </div>
            <button
              onClick={handleLogout}
              className="ml-2 rounded-lg px-3 py-1.5 text-sm text-gray-500 hover:bg-gray-100 hover:text-gray-700"
            >
              Logout
            </button>
          </div>
        </div>
      </div>

      {/* Mobile nav */}
      <nav className="flex items-center gap-1 overflow-x-auto border-t border-gray-100 px-4 py-2 md:hidden">
        {navLink("/", "Feed")}
        {navLink("/jobs", "Jobs")}
        {navLink("/events", "Events")}
        {navLink("/research", "Research")}
        {navLink("/chat", "Chat")}
        {navLink("/mentorship", "Mentorship")}
        {user?.role === "ADMIN" && navLink("/admin", "Admin")}
      </nav>
    </header>
  );
}
