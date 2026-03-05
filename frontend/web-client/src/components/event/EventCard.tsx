import type { EventResponse } from "../../types";
import { formatDate, formatTime } from "../../utils/formatDate";

interface EventCardProps {
  event: EventResponse;
  onRsvp?: (event: EventResponse) => void;
  onViewDetails?: (event: EventResponse) => void;
}

export default function EventCard({
  event,
  onRsvp,
  onViewDetails,
}: EventCardProps) {
  const categoryColors: Record<string, string> = {
    ACADEMIC: "bg-blue-50 text-blue-700",
    SOCIAL: "bg-pink-50 text-pink-700",
    WORKSHOP: "bg-yellow-50 text-yellow-700",
    NETWORKING: "bg-green-50 text-green-700",
    CAREER: "bg-purple-50 text-purple-700",
    ALUMNI: "bg-orange-50 text-orange-700",
  };

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md">
      <div className="flex items-start justify-between">
        <span
          className={`rounded-full px-3 py-1 text-xs font-medium ${categoryColors[event.category] || "bg-gray-50 text-gray-700"}`}
        >
          {event.category}
        </span>
        <span className="text-sm text-gray-500">
          {event.attendeeCount} attending
        </span>
      </div>
      <h3 className="mt-3 text-lg font-semibold text-gray-900">
        {event.title}
      </h3>
      <p className="mt-1 line-clamp-2 text-sm text-gray-600">
        {event.description}
      </p>
      <div className="mt-3 space-y-1 text-sm text-gray-500">
        <p className="flex items-center gap-1.5">
          <svg
            className="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
            />
          </svg>
          {formatDate(event.eventDate)}
        </p>
        {event.startTime && (
          <p className="flex items-center gap-1.5">
            <svg
              className="h-4 w-4"
              fill="none"
              viewBox="0 0 24 24"
              stroke="currentColor"
              strokeWidth={2}
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
              />
            </svg>
            {formatTime(event.startTime)} - {formatTime(event.endTime)}
          </p>
        )}
        <p className="flex items-center gap-1.5">
          <svg
            className="h-4 w-4"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
            strokeWidth={2}
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
            />
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
            />
          </svg>
          {event.location}
        </p>
      </div>
      <div className="mt-4 flex gap-2">
        {onViewDetails && (
          <button
            onClick={() => onViewDetails(event)}
            className="flex-1 rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            View Details
          </button>
        )}
        {onRsvp && (
          <button
            onClick={() => onRsvp(event)}
            className="flex-1 rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
          >
            RSVP
          </button>
        )}
      </div>
    </div>
  );
}
