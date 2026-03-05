import api from "./api";
import type {
  ResearchResponse,
  ResearchRequest,
  ResearchVersionResponse,
} from "../types";

export const researchService = {
  getAll: (params?: { category?: string; search?: string }) =>
    api.get<ResearchResponse[]>("/api/research", { params }),

  getById: (id: number) => api.get<ResearchResponse>(`/api/research/${id}`),

  create: (data: ResearchRequest) =>
    api.post<ResearchResponse>("/api/research", data),

  update: (id: number, data: ResearchRequest) =>
    api.put<ResearchResponse>(`/api/research/${id}`, data),

  remove: (id: number) => api.delete(`/api/research/${id}`),

  getByUser: (userId: string) =>
    api.get<ResearchResponse[]>(`/api/research/user/${userId}`),

  getByTag: (tag: string) =>
    api.get<ResearchResponse[]>(`/api/research/tag/${tag}`),

  addVersion: (id: number, data: { changeLog: string; documentUrl: string }) =>
    api.post<ResearchVersionResponse>(`/api/research/${id}/version`, data),

  getVersions: (id: number) =>
    api.get<ResearchVersionResponse[]>(`/api/research/${id}/versions`),

  cite: (id: number) => api.post(`/api/research/${id}/cite`),

  download: (id: number) => api.post(`/api/research/${id}/download`),
};
