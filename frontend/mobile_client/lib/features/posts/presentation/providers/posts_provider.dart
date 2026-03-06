import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/post_remote_datasource.dart';
import '../../data/models/post_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PostsState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostsState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PostsNotifier extends Notifier<PostsState> {
  @override
  PostsState build() {
    _init();
    return const PostsState();
  }

  Future<void> _init() async {
    await loadPosts();
  }

  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await ref.read(postDatasourceProvider).getPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createPost(String content,
      {List<String> mediaUrls = const []}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      final post = await ref.read(postDatasourceProvider).createPost(
            userId: user.id,
            fullName: user.fullName,
            content: content,
            mediaUrls: mediaUrls,
          );
      state = state.copyWith(posts: [post, ...state.posts]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    // Optimistic update
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      final liked = p.likedBy.contains(user.id);
      final newLikedBy = liked
          ? (List<int>.from(p.likedBy)..remove(user.id))
          : [...p.likedBy, user.id];
      return PostModel(
        id: p.id,
        userId: p.userId,
        username: p.username,
        fullName: p.fullName,
        content: p.content,
        mediaUrls: p.mediaUrls,
        likedBy: newLikedBy,
        comments: p.comments,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
      );
    }).toList();
    state = state.copyWith(posts: posts);
    try {
      await ref.read(postDatasourceProvider).likePost(postId, user.id);
    } catch (_) {
      // Revert on failure
      loadPosts();
    }
  }

  Future<bool> addComment(String postId, String text) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      await ref
          .read(postDatasourceProvider)
          .commentPost(postId, user.id, user.username, text);
      loadPosts();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final postsProvider =
    NotifierProvider<PostsNotifier, PostsState>(PostsNotifier.new);
