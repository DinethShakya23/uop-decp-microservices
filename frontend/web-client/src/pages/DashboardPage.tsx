import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { postService } from "../services/post";
import { eventService } from "../services/event";
import type { Post, EventResponse } from "../types";
import PostCard from "../components/post/PostCard";
import PostModal from "../components/post/PostModal";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorAlert from "../components/common/ErrorAlert";
import { formatDate } from "../utils/formatDate";

export default function DashboardPage() {
  const { user } = useAuth();
  const [posts, setPosts] = useState<Post[]>([]);
  const [upcomingEvents, setUpcomingEvents] = useState<EventResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showPostModal, setShowPostModal] = useState(false);

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    setLoading(true);
    setError("");
    try {
      const [postsRes, eventsRes] = await Promise.all([
        postService.getAll(),
        eventService.getUpcoming().catch(() => ({ data: [] })),
      ]);
      setPosts(postsRes.data);
      setUpcomingEvents(eventsRes.data.slice(0, 5));
    } catch {
      setError("Failed to load feed");
    }
    setLoading(false);
  };

  const handlePostCreated = (post: Post) => {
    setPosts((prev) => [post, ...prev]);
  };

  const handlePostUpdate = (updated: Post) => {
    setPosts((prev) => prev.map((p) => (p.id === updated.id ? updated : p)));
  };

  if (loading) return <LoadingSpinner />;

  return (
    <div className="mx-auto max-w-7xl px-4 py-6">
      <div className="grid gap-6 lg:grid-cols-3">
        {/* Main Feed */}
        <div className="lg:col-span-2">
          {/* Create Post */}
          <div className="mb-6 rounded-xl border border-gray-200 bg-white p-4 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-10 w-10 items-center justify-center rounded-full bg-primary-100 text-sm font-semibold text-primary-700">
                {user?.fullName?.charAt(0).toUpperCase()}
              </div>
              <button
                onClick={() => setShowPostModal(true)}
                className="flex-1 rounded-lg bg-gray-50 px-4 py-2.5 text-left text-sm text-gray-500 hover:bg-gray-100"
              >
                What's on your mind, {user?.fullName?.split(" ")[0]}?
              </button>
            </div>
          </div>

          <ErrorAlert message={error} onClose={() => setError("")} />

          {/* Posts */}
          <div className="space-y-4">
            {posts.length === 0 && !loading && (
              <div className="rounded-xl border border-gray-200 bg-white p-8 text-center text-gray-500">
                <p className="text-lg">No posts yet</p>
                <p className="text-sm">Be the first to share something!</p>
              </div>
            )}
            {posts.map((post) => (
              <PostCard key={post.id} post={post} onUpdate={handlePostUpdate} />
            ))}
          </div>
        </div>

        {/* Sidebar */}
        <div className="space-y-6">
          {/* Profile Card */}
          <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <div className="flex items-center gap-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-full bg-primary-100 text-lg font-bold text-primary-700">
                {user?.fullName?.charAt(0).toUpperCase()}
              </div>
              <div>
                <p className="font-semibold text-gray-900">{user?.fullName}</p>
                <p className="text-sm text-gray-500">
                  @{user?.username} · {user?.role}
                </p>
              </div>
            </div>
          </div>

          {/* Upcoming Events */}
          <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <h3 className="mb-3 font-semibold text-gray-900">
              Upcoming Events
            </h3>
            {upcomingEvents.length === 0 ? (
              <p className="text-sm text-gray-500">No upcoming events</p>
            ) : (
              <div className="space-y-3">
                {upcomingEvents.map((event) => (
                  <div key={event.id} className="flex items-start gap-3">
                    <div className="flex h-10 w-10 flex-shrink-0 items-center justify-center rounded-lg bg-primary-50 text-xs font-medium text-primary-700">
                      {new Date(event.eventDate).getDate()}
                    </div>
                    <div className="min-w-0">
                      <p className="truncate text-sm font-medium text-gray-900">
                        {event.title}
                      </p>
                      <p className="text-xs text-gray-500">
                        {formatDate(event.eventDate)}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      <PostModal
        open={showPostModal}
        onClose={() => setShowPostModal(false)}
        onCreated={handlePostCreated}
      />
    </div>
  );
}
