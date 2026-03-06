import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/jobs_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class JobDetailScreen extends ConsumerWidget {
  final int jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(singleJobProvider(jobId));
    final user = ref.watch(currentUserProvider);
    final isStudent = user?.role == 'STUDENT';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: jobAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (job) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.work_rounded,
                              size: 30, color: Color(0xFF1565C0)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(job.title,
                                  style: Theme.of(context).textTheme.headlineSmall),
                              Text(job.company,
                                  style: Theme.of(context).textTheme.titleSmall),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _InfoRow(Icons.location_on_outlined, job.location),
                      const SizedBox(height: 6),
                      _InfoRow(Icons.work_outline, job.type),
                      const SizedBox(height: 6),
                      _InfoRow(Icons.person_outline, 'Posted by ${job.posterName}'),
                      if (job.createdAt != null) ...[
                        const SizedBox(height: 6),
                        _InfoRow(Icons.access_time_outlined, timeAgo(job.createdAt!)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Description', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(job.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
              const SizedBox(height: 30),
              if (isStudent)
                ElevatedButton.icon(
                  onPressed: () => context.push('/jobs/${job.id}/apply'),
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Apply Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: const Color(0xFF9E9E9E)),
      const SizedBox(width: 8),
      Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
    ]);
  }
}
