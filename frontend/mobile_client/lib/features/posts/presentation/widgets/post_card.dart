import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/post_model.dart';
import '../providers/posts_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class PostCard extends ConsumerWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  void _showCommentSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Add a comment',
                  style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              // Existing comments
              if (post.comments.isNotEmpty) ...[
                SizedBox(
                  height: 160,
                  child: ListView.builder(
                    itemCount: post.comments.length,
                    itemBuilder: (_, i) {
                      final c = post.comments[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                          child: Text(c.username.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1565C0))),
                        ),
                        title: Text(c.username, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        subtitle: Text(c.text, style: const TextStyle(fontSize: 13)),
                      );
                    },
                  ),
                ),
                const Divider(),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Consumer(builder: (ctx2, ref2, _) {
                    return IconButton(
                      icon: const Icon(Icons.send_rounded, color: Color(0xFF1565C0)),
                      onPressed: () async {
                        final text = ctrl.text.trim();
                        if (text.isEmpty) return;
                        await ref2.read(postsProvider.notifier).addComment(post.id, text);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final isLiked = currentUser != null && post.likedBy.contains(currentUser.id);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                  child: Text(
                    (post.fullName.isNotEmpty ? post.fullName[0] : '?').toUpperCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFF1565C0)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.fullName, style: theme.textTheme.titleMedium),
                      Text('@${post.username}',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(timeAgo(post.createdAt), style: theme.textTheme.bodySmall),
              ],
            ),

            // Content
            const SizedBox(height: 12),
            Text(post.content, style: theme.textTheme.bodyLarge),

            // Media
            if (post.mediaUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  post.mediaUrls.first,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ],

            // Actions
            const SizedBox(height: 12),
            const Divider(height: 1),
            Row(
              children: [
                // Like
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isLiked ? Colors.red : const Color(0xFF9E9E9E),
                    size: 22,
                  ),
                  onPressed: () =>
                      ref.read(postsProvider.notifier).toggleLike(post.id),
                ),
                Text('${post.likedBy.length}',
                    style: const TextStyle(color: Color(0xFF757575), fontSize: 13)),
                const SizedBox(width: 8),
                // Comment
                IconButton(
                  icon: const Icon(Icons.comment_outlined,
                      color: Color(0xFF9E9E9E), size: 22),
                  onPressed: () => _showCommentSheet(context, ref),
                ),
                Text('${post.comments.length}',
                    style: const TextStyle(color: Color(0xFF757575), fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
