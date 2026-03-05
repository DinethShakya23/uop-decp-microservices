import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import { jobService } from "../services/job";
import type { Job } from "../types";
import JobCard from "../components/job/JobCard";
import JobApplicationModal from "../components/job/JobApplicationModal";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorAlert from "../components/common/ErrorAlert";

export default function JobsPage() {
  const { user } = useAuth();
  const [jobs, setJobs] = useState<Job[]>([]);
  const [filtered, setFiltered] = useState<Job[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [typeFilter, setTypeFilter] = useState("");
  const [selectedJob, setSelectedJob] = useState<Job | null>(null);
  const [showApplyModal, setShowApplyModal] = useState(false);
  const [showCreateForm, setShowCreateForm] = useState(false);

  // Create job fields
  const [newTitle, setNewTitle] = useState("");
  const [newCompany, setNewCompany] = useState("");
  const [newLocation, setNewLocation] = useState("");
  const [newType, setNewType] = useState("FULL_TIME");
  const [newDescription, setNewDescription] = useState("");
  const [creating, setCreating] = useState(false);

  useEffect(() => {
    loadJobs();
  }, []);

  useEffect(() => {
    let result = jobs;
    if (search.trim()) {
      const q = search.toLowerCase();
      result = result.filter(
        (j) =>
          j.title.toLowerCase().includes(q) ||
          j.company.toLowerCase().includes(q),
      );
    }
    if (typeFilter) {
      result = result.filter((j) => j.type === typeFilter);
    }
    setFiltered(result);
  }, [jobs, search, typeFilter]);

  const loadJobs = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await jobService.getAll();
      setJobs(res.data);
    } catch {
      setError("Failed to load jobs");
    }
    setLoading(false);
  };

  const handleApply = (job: Job) => {
    setSelectedJob(job);
    setShowApplyModal(true);
  };

  const handleCreateJob = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTitle.trim() || !newCompany.trim()) return;
    setCreating(true);
    try {
      await jobService.create({
        title: newTitle.trim(),
        company: newCompany.trim(),
        location: newLocation.trim(),
        type: newType,
        description: newDescription.trim(),
        postedBy: String(user?.id),
        posterName: user?.fullName || "",
      });
      setShowCreateForm(false);
      setNewTitle("");
      setNewCompany("");
      setNewLocation("");
      setNewDescription("");
      loadJobs();
    } catch {
      setError("Failed to create job");
    }
    setCreating(false);
  };

  if (loading) return <LoadingSpinner />;

  return (
    <div className="mx-auto max-w-7xl px-4 py-6">
      <div className="mb-6 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
        <h1 className="text-2xl font-bold text-gray-900">Job Board</h1>
        {(user?.role === "ALUMNI" || user?.role === "ADMIN") && (
          <button
            onClick={() => setShowCreateForm(!showCreateForm)}
            className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
          >
            + Post a Job
          </button>
        )}
      </div>

      {/* Create Job Form */}
      {showCreateForm && (
        <div className="mb-6 rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <h3 className="mb-4 font-semibold text-gray-900">Post New Job</h3>
          <form
            onSubmit={handleCreateJob}
            className="grid gap-4 sm:grid-cols-2"
          >
            <input
              value={newTitle}
              onChange={(e) => setNewTitle(e.target.value)}
              placeholder="Job Title *"
              required
              className="rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            />
            <input
              value={newCompany}
              onChange={(e) => setNewCompany(e.target.value)}
              placeholder="Company *"
              required
              className="rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            />
            <input
              value={newLocation}
              onChange={(e) => setNewLocation(e.target.value)}
              placeholder="Location"
              className="rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            />
            <select
              value={newType}
              onChange={(e) => setNewType(e.target.value)}
              className="rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            >
              <option value="FULL_TIME">Full Time</option>
              <option value="PART_TIME">Part Time</option>
              <option value="INTERNSHIP">Internship</option>
              <option value="CONTRACT">Contract</option>
            </select>
            <textarea
              value={newDescription}
              onChange={(e) => setNewDescription(e.target.value)}
              placeholder="Description"
              rows={3}
              className="sm:col-span-2 rounded-lg border border-gray-300 px-3 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            />
            <div className="sm:col-span-2 flex justify-end gap-3">
              <button
                type="button"
                onClick={() => setShowCreateForm(false)}
                className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={creating}
                className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
              >
                {creating ? "Posting..." : "Post Job"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Filters */}
      <div className="mb-6 flex flex-col gap-3 sm:flex-row">
        <input
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          placeholder="Search jobs by title or company..."
          className="flex-1 rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
        />
        <select
          value={typeFilter}
          onChange={(e) => setTypeFilter(e.target.value)}
          className="rounded-lg border border-gray-300 px-4 py-2.5 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
        >
          <option value="">All Types</option>
          <option value="FULL_TIME">Full Time</option>
          <option value="PART_TIME">Part Time</option>
          <option value="INTERNSHIP">Internship</option>
          <option value="CONTRACT">Contract</option>
        </select>
      </div>

      <ErrorAlert message={error} onClose={() => setError("")} />

      {/* Jobs Grid */}
      <div className="grid gap-4 md:grid-cols-2">
        {filtered.length === 0 ? (
          <div className="md:col-span-2 rounded-xl border border-gray-200 bg-white p-8 text-center text-gray-500">
            No jobs found
          </div>
        ) : (
          filtered.map((job) => (
            <JobCard
              key={job.id}
              job={job}
              onApply={user?.role === "STUDENT" ? handleApply : undefined}
            />
          ))
        )}
      </div>

      <JobApplicationModal
        open={showApplyModal}
        job={selectedJob}
        onClose={() => setShowApplyModal(false)}
        onApplied={() => {}}
      />
    </div>
  );
}
