import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { analyticsService } from "../services/analytics";
import type { AnalyticsOverview } from "../types";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorAlert from "../components/common/ErrorAlert";

export default function AdminPage() {
  const { user } = useAuth();
  const [overview, setOverview] = useState<AnalyticsOverview | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [activeSection, setActiveSection] = useState<
    "overview" | "users" | "posts" | "jobs" | "events"
  >("overview");
  const [sectionData, setSectionData] = useState<Record<
    string,
    unknown
  > | null>(null);
  const [sectionLoading, setSectionLoading] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const res = await analyticsService.getOverview();
        setOverview(res.data);
      } catch {
        setError("Failed to load analytics");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  useEffect(() => {
    if (activeSection === "overview") {
      setSectionData(null);
      return;
    }
    const fetchers: Record<string, () => Promise<{ data: unknown }>> = {
      users: analyticsService.getUserMetrics,
      posts: analyticsService.getPostMetrics,
      jobs: analyticsService.getJobMetrics,
      events: analyticsService.getEventMetrics,
    };
    (async () => {
      try {
        setSectionLoading(true);
        const res = await fetchers[activeSection]();
        setSectionData(res.data as Record<string, unknown>);
      } catch {
        /* ignore */
      } finally {
        setSectionLoading(false);
      }
    })();
  }, [activeSection]);

  if (user?.role !== "ADMIN") {
    return (
      <div className="flex min-h-[50vh] items-center justify-center">
        <div className="text-center">
          <h2 className="text-xl font-bold text-gray-900">Access Denied</h2>
          <p className="text-gray-500">Admin privileges required.</p>
        </div>
      </div>
    );
  }

  if (loading) return <LoadingSpinner />;
  if (error) return <ErrorAlert message={error} onClose={() => setError("")} />;

  const statCards = [
    {
      label: "Total Users",
      value: overview?.totalUsers ?? "-",
      color: "bg-blue-500",
    },
    {
      label: "Total Posts",
      value: overview?.totalPosts ?? "-",
      color: "bg-green-500",
    },
    {
      label: "Total Jobs",
      value: overview?.totalJobs ?? "-",
      color: "bg-purple-500",
    },
    {
      label: "Total Events",
      value: overview?.totalEvents ?? "-",
      color: "bg-orange-500",
    },
    {
      label: "Active Users",
      value: overview?.activeUsers ?? "-",
      color: "bg-teal-500",
    },
  ];

  const sections: { key: typeof activeSection; label: string }[] = [
    { key: "overview", label: "Overview" },
    { key: "users", label: "Users" },
    { key: "posts", label: "Posts" },
    { key: "jobs", label: "Jobs" },
    { key: "events", label: "Events" },
  ];

  return (
    <div className="mx-auto max-w-7xl px-4 py-6">
      <h1 className="mb-6 text-2xl font-bold text-gray-900">Admin Dashboard</h1>

      <div className="mb-8 grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
        {statCards.map((s) => (
          <div
            key={s.label}
            className="rounded-xl bg-white p-4 shadow-sm border border-gray-200"
          >
            <div
              className={`mb-2 inline-block h-2 w-8 rounded-full ${s.color}`}
            />
            <p className="text-2xl font-bold text-gray-900">{s.value}</p>
            <p className="text-xs text-gray-500">{s.label}</p>
          </div>
        ))}
      </div>

      <div className="mb-6 flex gap-1 rounded-lg bg-gray-100 p-1">
        {sections.map((s) => (
          <button
            key={s.key}
            onClick={() => setActiveSection(s.key)}
            className={`flex-1 rounded-md px-4 py-2 text-sm font-medium transition ${
              activeSection === s.key
                ? "bg-white text-primary-700 shadow-sm"
                : "text-gray-600 hover:text-gray-900"
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {activeSection === "overview" && overview ? (
        <div className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900">
            Platform Overview
          </h2>
          <div className="space-y-3">
            {(Object.keys(overview) as Array<keyof AnalyticsOverview>).map(
              (key) => (
                <div
                  key={key}
                  className="flex items-center justify-between border-b border-gray-100 pb-2"
                >
                  <span className="text-sm text-gray-600 capitalize">
                    {String(key)
                      .replace(/([A-Z])/g, " $1")
                      .trim()}
                  </span>
                  <span className="font-medium text-gray-900">
                    {overview[key].toLocaleString()}
                  </span>
                </div>
              ),
            )}
          </div>
        </div>
      ) : sectionLoading ? (
        <LoadingSpinner />
      ) : sectionData ? (
        <div className="rounded-xl border border-gray-200 bg-white p-6">
          <h2 className="mb-4 text-lg font-semibold text-gray-900 capitalize">
            {activeSection} Metrics
          </h2>
          <div className="space-y-3">
            {Object.entries(sectionData).map(([key, val]) => (
              <div
                key={key}
                className="flex items-center justify-between border-b border-gray-100 pb-2"
              >
                <span className="text-sm text-gray-600 capitalize">
                  {key.replace(/([A-Z])/g, " $1").trim()}
                </span>
                <span className="font-medium text-gray-900">
                  {typeof val === "number"
                    ? val.toLocaleString()
                    : typeof val === "object"
                      ? JSON.stringify(val)
                      : String(val ?? "-")}
                </span>
              </div>
            ))}
          </div>
        </div>
      ) : activeSection !== "overview" ? (
        <p className="text-center text-gray-500">No data available.</p>
      ) : null}
    </div>
  );
}
