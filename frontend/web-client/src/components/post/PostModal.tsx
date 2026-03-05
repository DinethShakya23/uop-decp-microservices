import { useState } from "react";
import { useAuth } from "../../context/AuthContext";
import { postService } from "../../services/post";
import type { Post } from "../../types";

interface PostModalProps {
  open: boolean;
  onClose: () => void;
  onCreated: (post: Post) => void;
}

export default function PostModal({
  open,
  onClose,
  onCreated,
}: PostModalProps) {
  const { user } = useAuth();
  const [content, setContent] = useState("");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  if (!open || !user) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!content.trim()) return;
    setSubmitting(true);
    setError("");
    try {
      const res = await postService.create({
        userId: String(user.id),
        fullName: user.fullName,
        content: content.trim(),
      });
      onCreated(res.data);
      setContent("");
      onClose();
    } catch {
      setError("Failed to create post");
    }
    setSubmitting(false);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40">
      <div className="w-full max-w-lg rounded-xl bg-white p-6 shadow-xl">
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">Create Post</h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-600"
          >
            ✕
          </button>
        </div>
        <form onSubmit={handleSubmit} className="mt-4">
          <textarea
            value={content}
            onChange={(e) => setContent(e.target.value)}
            placeholder="What's on your mind?"
            rows={4}
            className="w-full rounded-lg border border-gray-200 p-3 text-sm focus:border-primary-500 focus:outline-none focus:ring-1 focus:ring-primary-500"
            autoFocus
          />
          {error && <p className="mt-2 text-sm text-red-500">{error}</p>}
          <div className="mt-4 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="rounded-lg border border-gray-300 px-4 py-2 text-sm font-medium text-gray-700 hover:bg-gray-50"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={!content.trim() || submitting}
              className="rounded-lg bg-primary-600 px-4 py-2 text-sm font-medium text-white hover:bg-primary-700 disabled:opacity-50"
            >
              {submitting ? "Posting..." : "Post"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
