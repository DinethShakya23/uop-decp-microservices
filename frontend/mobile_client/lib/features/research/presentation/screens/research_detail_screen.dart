import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/research_remote_datasource.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class ResearchDetailScreen extends ConsumerWidget {
  final int researchId;
  const ResearchDetailScreen({super.key, required this.researchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final researchAsync = ref.watch(singleResearchProvider(researchId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Research')),
      body: researchAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (r) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(r.category,
                    style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Text(r.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text('By ${r.authors.join(', ')}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF757575))),
              if (r.doi != null) ...[
                const SizedBox(height: 4),
                Text('DOI: ${r.doi}', style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
              ],
              if (r.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: r.tags.map((t) => Chip(
                  label: Text(t, style: const TextStyle(fontSize: 11)),
                )).toList()),
              ],
              const SizedBox(height: 20),
              Text('Abstract', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(r.researchAbstract,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
              if (r.documentUrl != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(researchDatasourceProvider).download(r.id!);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Document: ${r.documentUrl}')));
                    }
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download Paper'),
                ),
              ],

              // Admin/author delete
              if (user?.role == 'ADMIN' || (r.postedBy != null && r.postedBy == user?.id)) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
                  onPressed: () async {
                    await ref.read(researchProvider.notifier).delete(r.id!);
                    if (context.mounted) context.pop();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
