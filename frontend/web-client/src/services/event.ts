import api from "./api";
import type {
  EventResponse,
  EventRequest,
  RsvpResponse,
  RsvpStatus,
} from "../types";

export const eventService = {
  getAll: () => api.get<EventResponse[]>("/api/events"),

  getUpcoming: () => api.get<EventResponse[]>("/api/events/upcoming"),

  getById: (id: number) => api.get<EventResponse>(`/api/events/${id}`),

  create: (data: EventRequest) => api.post<EventResponse>("/api/events", data),

  update: (id: number, data: EventRequest) =>
    api.put<EventResponse>(`/api/events/${id}`, data),

  remove: (id: number) => api.delete(`/api/events/${id}`),

  rsvp: (eventId: number, status: RsvpStatus) =>
    api.post<RsvpResponse>(`/api/events/${eventId}/rsvp`, { status }),

  getAttendees: (eventId: number) =>
    api.get<RsvpResponse[]>(`/api/events/${eventId}/attendees`),
};
