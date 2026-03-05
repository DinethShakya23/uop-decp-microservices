import { useState } from "react";
import type { Job } from "../../types";
import { useAuth } from "../../context/AuthContext";
import { jobService } from "../../services/job";

interface JobApplicationModalProps {
  open: boolean;
  job: Job | null;
  onClose: () => void;
  onApplied: () => void;
}

export default function JobApplicationModal({
  open,
  job,
  onClose,
  onApplied,
}: JobApplicationModalProps) {
  const { user } = useAuth();
  const [coverLetter, setCoverLetter] = useState("");
  const [resumeUrl, setResumeUrl] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  if (!open || !job || !user) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!coverLetter.trim()) return;
    setSubmitting(true);
    setError("");
    try {
      await jobService.apply(job.id, {
        userId: String(user.id),
        applicantName: user.fullName,
        coverLetter: coverLetter.trim(),
        resumeUrl: resumeUrl.trim() || undefined,
      });
      setCoverLetter("");
      setResumeUrl("");
      onApplied();
      onClose();
    } catch (err: any) {
      setError(err.response?.data?.message || "Failed to apply");
    }
    setSubmitting(false);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">
            Apply for {job.title}
          </h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
        <p className="mt-1 text-sm text-gray-500">{job.company}</p>
        <form onSubmit={handleSubmit} className="mt-4 space-y-4">
          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">
              Cover Letter *
            </label>
            <textarea
              value={coverLetter}
              onChange={(e) => setCoverLetter(e.target.value)}
              rows={5}
              className="w-full rounded-lg border border-gray-200 p-3 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
              placeholder="Tell us why you're a great fit..."
            />
          </div>
          <div>
            <label className="mb-1 block text-sm font-medium text-gray-700">
              Resume URL
            </label>
            <input
              value={resumeUrl}
              onChange={(e) => setResumeUrl(e.target.value)}
              className="w-full rounded-lg border border-gray-200 px-3 py-2 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
              placeholder="https://drive.google.com/..."
            />
          </div>
          {error && <p className="text-sm text-red-500">{error}</p>}
          <div className="flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!coverLetter.trim() || submitting}
              className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
            >
              {submitting ? "Submitting..." : "Submit Application"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
