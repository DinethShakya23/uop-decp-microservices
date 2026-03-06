import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/datasources/research_remote_datasource.dart';
import '../../data/models/research_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../core/utils/date_utils.dart';

class ResearchScreen extends ConsumerStatefulWidget {
  const ResearchScreen({super.key});

  @override
  ConsumerState<ResearchScreen> createState() => _ResearchScreenState();
}

class _ResearchScreenState extends ConsumerState<ResearchScreen> {
  final _searchCtrl = TextEditingController();
  String? _selectedCategory;

  static const _categories = ['PAPER', 'THESIS', 'PROJECT', 'ARTICLE', 'CONFERENCE', 'WORKSHOP'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(researchProvider.notifier).loadResearch());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(researchProvider);
    final user = ref.watch(currentUserProvider);
    final canCreate = user?.role == 'ALUMNI' || user?.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(title: const Text('Research')),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push('/research/create'),
              child: const Icon(Icons.add))
          : null,
      body: Column(
        children: [
          // Search + filter bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search research...',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchCtrl.clear();
                              ref.read(researchProvider.notifier).loadResearch();
                              setState(() {});
                            })
                        : null,
                  ),
                  onSubmitted: (q) {
                    ref.read(researchProvider.notifier)
                        .loadResearch(category: _selectedCategory, search: q.isEmpty ? null : q);
                  },
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String?>(
                value: _selectedCategory,
                hint: const Text('Category'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All')),
                  ..._categories.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                ],
                onChanged: (v) {
                  setState(() => _selectedCategory = v);
                  ref.read(researchProvider.notifier).loadResearch(
                      category: v, search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text);
                },
              ),
            ]),
          ),
          Expanded(
            child: Builder(builder: (_) {
              if (state.isLoading && state.items.isEmpty) {
                return const AppLoadingWidget(message: 'Loading research...');
              }
              if (state.error != null && state.items.isEmpty) {
                return AppErrorWidget(message: state.error!,
                    onRetry: () => ref.read(researchProvider.notifier).loadResearch());
              }
              if (state.items.isEmpty) {
                return const Center(child: Text('No research publications found.'));
              }
              return RefreshIndicator(
                onRefresh: () => ref.read(researchProvider.notifier).loadResearch(),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: state.items.length,
                  itemBuilder: (_, i) => _ResearchCard(item: state.items[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ResearchCard extends StatelessWidget {
  final ResearchModel item;
  const _ResearchCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/research/${item.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF6A1B9A).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(item.category,
                      style: const TextStyle(color: Color(0xFF6A1B9A), fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                if (item.downloads != null && item.downloads! > 0)
                  Row(children: [
                    const Icon(Icons.download_outlined, size: 14, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 3),
                    Text('${item.downloads}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                  ]),
              ]),
              const SizedBox(height: 8),
              Text(item.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(item.authors.join(', '),
                  style: Theme.of(context).textTheme.bodySmall),
              if (item.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: item.tags.take(3).map((t) => Chip(
                  label: Text(t, style: const TextStyle(fontSize: 10)),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList()),
              ],
              if (item.createdAt != null) ...[
                const SizedBox(height: 6),
                Text(timeAgo(item.createdAt!), style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
