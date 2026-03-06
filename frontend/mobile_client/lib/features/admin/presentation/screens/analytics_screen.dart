import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(analyticsOverviewProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: asyncData.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.refresh(analyticsOverviewProvider)),
        data: (data) => RefreshIndicator(
          onRefresh: () async => ref.refresh(analyticsOverviewProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Platform Overview',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    _StatCard(title: 'Total Users', value: '${data.totalUsers}',
                        icon: Icons.people_alt_rounded, color: const Color(0xFF1565C0)),
                    _StatCard(title: 'Active Today', value: '${data.activeUsersToday}',
                        icon: Icons.directions_run_rounded, color: const Color(0xFF43A047)),
                    _StatCard(title: 'Total Posts', value: '${data.totalPosts}',
                        icon: Icons.dynamic_feed_rounded, color: const Color(0xFFE53935)),
                    _StatCard(title: 'Jobs Posted', value: '${data.totalJobs}',
                        icon: Icons.work_rounded, color: const Color(0xFF8E24AA)),
                    _StatCard(title: 'Events', value: '${data.totalEvents}',
                        icon: Icons.event_rounded, color: const Color(0xFFF4511E)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Color(0xFF757575), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
