import api from "./api";
import type { Job, JobApplication } from "../types";

export const jobService = {
  getAll: () => api.get<Job[]>("/api/jobs"),

  getById: (id: number) => api.get<Job>(`/api/jobs/${id}`),

  create: (data: Partial<Job>) => api.post<Job>("/api/jobs", data),

  apply: (jobId: number, application: Partial<JobApplication>) =>
    api.post<JobApplication>(`/api/jobs/${jobId}/apply`, application),

  getApplications: (jobId: number) =>
    api.get<JobApplication[]>(`/api/jobs/${jobId}/applications`),

  getUserApplications: (userId: string) =>
    api.get<JobApplication[]>(`/api/jobs/user/${userId}/applications`),
};
