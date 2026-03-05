import { useState, useEffect, useCallback } from "react";
import { useAuth } from "../context/AuthContext";
import { researchService } from "../services/research";
import type { ResearchResponse, ResearchCategory } from "../types";
import LoadingSpinner from "../components/common/LoadingSpinner";
import ErrorAlert from "../components/common/ErrorAlert";
import { formatDate } from "../utils/formatDate";

const CATEGORIES: ResearchCategory[] = [
  "PAPER",
  "THESIS",
  "PROJECT",
  "ARTICLE",
  "CONFERENCE",
  "WORKSHOP",
];

export default function ResearchPage() {
  const { user } = useAuth();
  const [papers, setPapers] = useState<ResearchResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [search, setSearch] = useState("");
  const [category, setCategory] = useState("");
  const [showCreate, setShowCreate] = useState(false);
  const [selectedPaper, setSelectedPaper] = useState<ResearchResponse | null>(
    null,
  );

  const fetchPapers = useCallback(async () => {
    try {
      setLoading(true);
      const params: Record<string, string> = {};
      if (search) params.search = search;
      if (category) params.category = category;
      const res = await researchService.getAll(params);
      setPapers(res.data);
    } catch {
      setError("Failed to load research papers");
    } finally {
      setLoading(false);
    }
  }, [search, category]);

  useEffect(() => {
    fetchPapers();
  }, [fetchPapers]);

  const canCreate = user?.role === "ALUMNI" || user?.role === "ADMIN";

  return (
    <div className="mx-auto max-w-7xl px-4 py-6">
      <div className="mb-6 flex flex-wrap items-center justify-between gap-4">
        <h1 className="text-2xl font-bold text-gray-900">Research Papers</h1>
        {canCreate && (
          <button
            onClick={() => setShowCreate(true)}
            className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700"
          >
            + Publish Paper
          </button>
        )}
      </div>

      <div className="mb-6 flex flex-wrap gap-3">
        <input
          type="text"
          placeholder="Search papers..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="rounded-lg border border-gray-300 px-4 py-2 text-sm focus:border-primary-500 focus:ring-primary-500"
        />
        <select
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          className="rounded-lg border border-gray-300 px-4 py-2 text-sm focus:border-primary-500 focus:ring-primary-500"
        >
          <option value="">All Categories</option>
          {CATEGORIES.map((c) => (
            <option key={c} value={c}>
              {c.replace(/_/g, " ")}
            </option>
          ))}
        </select>
      </div>

      {error && <ErrorAlert message={error} onClose={() => setError("")} />}

      {loading ? (
        <LoadingSpinner />
      ) : papers.length === 0 ? (
        <div className="rounded-xl border border-gray-200 bg-white p-8 text-center text-gray-500">
          <p className="text-lg font-medium">No research papers found</p>
          <p className="text-sm">
            Try adjusting your filters or publish the first paper.
          </p>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {papers.map((paper) => (
            <PaperCard
              key={paper.id}
              paper={paper}
              onSelect={setSelectedPaper}
            />
          ))}
        </div>
      )}

      {showCreate && (
        <CreatePaperModal
          onClose={() => setShowCreate(false)}
          onCreated={() => {
            setShowCreate(false);
            fetchPapers();
          }}
        />
      )}

      {selectedPaper && (
        <PaperDetailModal
          paper={selectedPaper}
          onClose={() => setSelectedPaper(null)}
          onCite={async () => {
            try {
              await researchService.cite(selectedPaper.id);
              fetchPapers();
            } catch {
              /* ignore */
            }
          }}
        />
      )}
    </div>
  );
}

function PaperCard({
  paper,
  onSelect,
}: {
  paper: ResearchResponse;
  onSelect: (p: ResearchResponse) => void;
}) {
  return (
    <div
      className="cursor-pointer rounded-xl border border-gray-200 bg-white p-5 shadow-sm transition hover:shadow-md"
      onClick={() => onSelect(paper)}
    >
      <div className="mb-2 flex items-start justify-between gap-2">
        <span className="inline-block rounded-full bg-purple-100 px-2.5 py-0.5 text-xs font-medium text-purple-700">
          {paper.category?.replace(/_/g, " ") || "GENERAL"}
        </span>
        {paper.citations > 0 && (
          <span className="text-xs text-gray-500">
            {paper.citations} citations
          </span>
        )}
      </div>
      <h3 className="mb-1 line-clamp-2 font-semibold text-gray-900">
        {paper.title}
      </h3>
      <p className="mb-3 line-clamp-3 text-sm text-gray-600">
        {paper.researchAbstract}
      </p>
      <div className="flex flex-wrap gap-1.5">
        {paper.tags?.slice(0, 4).map((tag: string) => (
          <span
            key={tag}
            className="rounded-full bg-gray-100 px-2 py-0.5 text-xs text-gray-600"
          >
            {tag}
          </span>
        ))}
      </div>
      <p className="mt-3 text-xs text-gray-400">
        {formatDate(paper.createdAt)}
      </p>
    </div>
  );
}

function CreatePaperModal({
  onClose,
  onCreated,
}: {
  onClose: () => void;
  onCreated: () => void;
}) {
  const [title, setTitle] = useState("");
  const [researchAbstract, setResearchAbstract] = useState("");
  const [category, setCategory] = useState<ResearchCategory>("PAPER");
  const [tags, setTags] = useState("");
  const [authors, setAuthors] = useState("");
  const [documentUrl, setDocumentUrl] = useState("");
  const [doi, setDoi] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim() || !researchAbstract.trim()) return;
    try {
      setSubmitting(true);
      await researchService.create({
        title: title.trim(),
        researchAbstract: researchAbstract.trim(),
        category,
        tags: tags
          .split(",")
          .map((t) => t.trim())
          .filter(Boolean),
        authors: authors
          .split(",")
          .map((a) => a.trim())
          .filter(Boolean),
        documentUrl: documentUrl.trim() || undefined,
        doi: doi.trim() || undefined,
      });
      onCreated();
    } catch {
      setError("Failed to publish paper");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <div
        className="w-full max-w-lg rounded-2xl bg-white p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 className="mb-4 text-xl font-bold text-gray-900">
          Publish Research Paper
        </h2>
        {error && <ErrorAlert message={error} onClose={() => setError("")} />}
        <form onSubmit={handleSubmit} className="space-y-4">
          <input
            type="text"
            placeholder="Paper title"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            required
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
          <textarea
            placeholder="Abstract..."
            value={researchAbstract}
            onChange={(e) => setResearchAbstract(e.target.value)}
            rows={4}
            required
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
          <input
            type="text"
            placeholder="Authors (comma-separated)"
            value={authors}
            onChange={(e) => setAuthors(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
          <select
            value={category}
            onChange={(e) => setCategory(e.target.value as ResearchCategory)}
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          >
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>
                {c.replace(/_/g, " ")}
              </option>
            ))}
          </select>
          <input
            type="text"
            placeholder="Tags (comma-separated)"
            value={tags}
            onChange={(e) => setTags(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
          <input
            type="url"
            placeholder="Document URL (optional)"
            value={documentUrl}
            onChange={(e) => setDocumentUrl(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
          <input
            type="text"
            placeholder="DOI (optional)"
            value={doi}
            onChange={(e) => setDoi(e.target.value)}
            className="w-full rounded-lg border border-gray-300 px-4 py-2 focus:border-primary-500 focus:ring-primary-500"
          />
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
              disabled={submitting}
              className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
            >
              {submitting ? "Publishing..." : "Publish"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

function PaperDetailModal({
  paper,
  onClose,
  onCite,
}: {
  paper: ResearchResponse;
  onClose: () => void;
  onCite: () => void;
}) {
  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
    >
      <div
        className="max-h-[80vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white p-6"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="mb-2 flex items-start justify-between">
          <span className="inline-block rounded-full bg-purple-100 px-2.5 py-0.5 text-xs font-medium text-purple-700">
            {paper.category?.replace(/_/g, " ") || "GENERAL"}
          </span>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
        <h2 className="mb-2 text-xl font-bold text-gray-900">{paper.title}</h2>
        {paper.authors && paper.authors.length > 0 && (
          <p className="mb-1 text-sm text-gray-600">
            By {paper.authors.join(", ")}
          </p>
        )}
        <p className="mb-4 text-sm text-gray-500">
          Published {formatDate(paper.createdAt)}
        </p>
        <div className="mb-4 rounded-lg bg-gray-50 p-4">
          <h3 className="mb-1 text-sm font-semibold text-gray-700">Abstract</h3>
          <p className="text-sm text-gray-600 whitespace-pre-line">
            {paper.researchAbstract}
          </p>
        </div>
        {paper.tags && paper.tags.length > 0 && (
          <div className="mb-4 flex flex-wrap gap-2">
            {paper.tags.map((tag: string) => (
              <span
                key={tag}
                className="rounded-full bg-gray-100 px-3 py-1 text-xs font-medium text-gray-600"
              >
                {tag}
              </span>
            ))}
          </div>
        )}
        <div className="mb-4 flex gap-4 text-sm text-gray-500">
          <span>{paper.views} views</span>
          <span>{paper.downloads} downloads</span>
          <span>{paper.citations} citations</span>
        </div>
        <div className="flex items-center gap-4 border-t border-gray-200 pt-4">
          <button
            onClick={onCite}
            className="rounded-lg bg-purple-600 px-4 py-2 text-sm font-medium text-white hover:bg-purple-700"
          >
            Cite ({paper.citations})
          </button>
          {paper.documentUrl && (
            <a
              href={paper.documentUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              Download PDF
            </a>
          )}
        </div>
      </div>
    </div>
  );
}
