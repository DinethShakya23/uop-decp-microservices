import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/posts_provider.dart';
import '../widgets/post_card.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postsProvider.notifier).loadPosts());
  }

  Future<void> _refresh() => ref.read(postsProvider.notifier).loadPosts();

  void _showCreatePost() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text('Create Post', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Consumer(builder: (ctx2, ref2, _) {
                return ElevatedButton(
                  onPressed: () async {
                    final text = ctrl.text.trim();
                    if (text.isEmpty) return;
                    final ok = await ref2.read(postsProvider.notifier).createPost(text);
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                          content: Text(ok ? 'Post created!' : 'Failed to post')));
                    }
                  },
                  child: const Text('Post'),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Feed')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePost,
        child: const Icon(Icons.add),
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading && state.posts.isEmpty) {
            return const AppLoadingWidget(message: 'Loading posts...');
          }
          if (state.error != null && state.posts.isEmpty) {
            return AppErrorWidget(
                message: state.error!, onRetry: _refresh);
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: state.posts.isEmpty
                ? const Center(
                    child: Text('No posts yet. Be the first to post!'))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: state.posts.length,
                    itemBuilder: (_, i) => PostCard(post: state.posts[i]),
                  ),
          );
        },
      ),
    );
  }
}
