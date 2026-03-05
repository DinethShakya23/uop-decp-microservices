import type { Job } from "../../types";
import { formatDate } from "../../utils/formatDate";

interface JobCardProps {
  job: Job;
  onApply?: (job: Job) => void;
}

export default function JobCard({ job, onApply }: JobCardProps) {
  return (
    <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition-shadow hover:shadow-md">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900">{job.title}</h3>
          <p className="mt-1 text-sm text-gray-600">{job.company}</p>
        </div>
        {job.type && (
          <span className="rounded-full bg-primary-50 px-3 py-1 text-xs font-medium text-primary-700">
            {job.type.replace("_", " ")}
          </span>
        )}
      </div>
      <div className="mt-3 flex flex-wrap gap-4 text-sm text-gray-500">
        {job.location && (
          <span className="flex items-center gap-1">
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
            {job.location}
          </span>
        )}
        <span className="flex items-center gap-1">
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
          {formatDate(job.createdAt)}
        </span>
      </div>
      <p className="mt-3 line-clamp-2 text-sm text-gray-600">
        {job.description}
      </p>
      <div className="mt-4 flex items-center justify-between">
        <span className="text-xs text-gray-400">
          Posted by {job.posterName}
        </span>
        {onApply && (
          <button
            onClick={() => onApply(job)}
            className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
          >
            Apply
          </button>
        )}
      </div>
    </div>
  );
}
