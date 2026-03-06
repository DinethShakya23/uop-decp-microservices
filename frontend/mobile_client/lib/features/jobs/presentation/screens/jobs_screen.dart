import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_provider.dart';
import '../../data/models/job_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(jobsProvider.notifier).loadJobs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(jobsProvider);
    final user = ref.watch(currentUserProvider);
    final canCreate = user?.role == 'ALUMNI' || user?.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push('/jobs/create'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Builder(builder: (_) {
        if (state.isLoading && state.jobs.isEmpty) {
          return const AppLoadingWidget(message: 'Loading jobs...');
        }
        if (state.error != null && state.jobs.isEmpty) {
          return AppErrorWidget(
              message: state.error!,
              onRetry: () => ref.read(jobsProvider.notifier).loadJobs());
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(jobsProvider.notifier).loadJobs(),
          child: state.jobs.isEmpty
              ? const Center(child: Text('No jobs available.'))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: state.jobs.length,
                  itemBuilder: (_, i) => _JobCard(job: state.jobs[i]),
                ),
        );
      }),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobModel job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/jobs/${job.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.work_rounded, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(job.company,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(job.type,
                      style: const TextStyle(
                          color: Color(0xFF00897B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(job.location, style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                if (job.createdAt != null)
                  Text(timeAgo(job.createdAt!), style: Theme.of(context).textTheme.bodySmall),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
