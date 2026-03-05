import api from "./api";
import type {
  AnalyticsOverview,
  UserMetrics,
  PostMetrics,
  JobMetrics,
  EventMetrics,
  TimelineEntry,
} from "../types";

export const analyticsService = {
  getOverview: () => api.get<AnalyticsOverview>("/api/analytics/overview"),

  getUserMetrics: () => api.get<UserMetrics>("/api/analytics/users"),

  getPostMetrics: () => api.get<PostMetrics>("/api/analytics/posts"),

  getJobMetrics: () => api.get<JobMetrics>("/api/analytics/jobs"),

  getEventMetrics: () => api.get<EventMetrics>("/api/analytics/events"),

  getTimeline: (from: string, to: string) =>
    api.get<TimelineEntry[]>("/api/analytics/timeline", {
      params: { from, to },
    }),

  exportData: (format: string, type: string) =>
    api.get("/api/analytics/export", {
      params: { format, type },
      responseType: "blob",
    }),
};
