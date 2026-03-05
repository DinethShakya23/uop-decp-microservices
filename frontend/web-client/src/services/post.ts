import api from "./api";
import type { Post, PostRequest } from "../types";

export const postService = {
  getAll: () => api.get<Post[]>("/api/posts"),

  create: (data: PostRequest) => api.post<Post>("/api/posts", data),

  like: (postId: string, userId: string) =>
    api.post<Post>(`/api/posts/${postId}/like`, { userId }),

  addComment: (
    postId: string,
    comment: { userId: string; username: string; text: string },
  ) => api.post<Post>(`/api/posts/${postId}/comment`, comment),
};
