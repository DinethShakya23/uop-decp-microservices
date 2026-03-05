import api from "./api";
import type {
  MentorshipProfileResponse,
  MentorshipProfileRequest,
  MentorshipMatchDTO,
  MentorshipRequestResponse,
  MentorshipRequestRequest,
  MentorshipRelationshipResponse,
  MentorshipFeedbackDTO,
} from "../types";

export const mentorshipService = {
  // Profile
  createProfile: (data: MentorshipProfileRequest) =>
    api.post<MentorshipProfileResponse>("/api/mentorship/profile", data),

  getMyProfile: () =>
    api.get<MentorshipProfileResponse>("/api/mentorship/profile"),

  getProfile: (userId: number) =>
    api.get<MentorshipProfileResponse>(`/api/mentorship/profile/${userId}`),

  // Matches
  getMatches: () => api.get<MentorshipMatchDTO[]>("/api/mentorship/matches"),

  getAdvancedMatches: (params?: {
    expertise?: string;
    availability?: string;
    department?: string;
  }) =>
    api.get<MentorshipMatchDTO[]>("/api/mentorship/matches/advanced", {
      params,
    }),

  // Requests
  sendRequest: (data: MentorshipRequestRequest) =>
    api.post<MentorshipRequestResponse>("/api/mentorship/request", data),

  updateRequest: (
    id: number,
    data: { status: string; rejectionReason?: string },
  ) =>
    api.put<MentorshipRequestResponse>(`/api/mentorship/request/${id}`, data),

  getRequest: (id: number) =>
    api.get<MentorshipRequestResponse>(`/api/mentorship/request/${id}`),

  getMyRequests: () =>
    api.get<MentorshipRequestResponse[]>("/api/mentorship/requests"),

  // Relationships
  getRelationships: () =>
    api.get<MentorshipRelationshipResponse[]>("/api/mentorship/relationships"),

  getRelationship: (id: number) =>
    api.get<MentorshipRelationshipResponse>(
      `/api/mentorship/relationships/${id}`,
    ),

  updateRelationship: (
    id: number,
    data: Partial<MentorshipRelationshipResponse>,
  ) =>
    api.put<MentorshipRelationshipResponse>(
      `/api/mentorship/relationships/${id}`,
      data,
    ),

  endRelationship: (id: number) =>
    api.delete(`/api/mentorship/relationships/${id}`),

  // Feedback
  addFeedback: (
    relationshipId: number,
    data: { rating: number; message: string },
  ) =>
    api.post<MentorshipFeedbackDTO>(
      `/api/mentorship/relationships/${relationshipId}/feedback`,
      data,
    ),

  getFeedback: (relationshipId: number) =>
    api.get<MentorshipFeedbackDTO[]>(
      `/api/mentorship/relationships/${relationshipId}/feedback`,
    ),
};
