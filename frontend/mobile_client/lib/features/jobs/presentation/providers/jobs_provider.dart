import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/job_remote_datasource.dart';
import '../../data/models/job_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class JobsState {
  final List<JobModel> jobs;
  final bool isLoading;
  final String? error;

  const JobsState({this.jobs = const [], this.isLoading = false, this.error});

  JobsState copyWith(
          {List<JobModel>? jobs,
          bool? isLoading,
          String? error,
          bool clearError = false}) =>
      JobsState(
        jobs: jobs ?? this.jobs,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class JobsNotifier extends Notifier<JobsState> {
  @override
  JobsState build() {
    _init();
    return const JobsState();
  }

  Future<void> _init() async {
    await loadJobs();
  }

  Future<void> loadJobs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final jobs = await ref.read(jobDatasourceProvider).getJobs();
      state = state.copyWith(jobs: jobs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createJob({
    required String title,
    required String description,
    required String company,
    required String location,
    required String type,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      final job = await ref.read(jobDatasourceProvider).createJob({
        'title': title,
        'description': description,
        'company': company,
        'location': location,
        'type': type,
        'postedBy': user.id,
        'posterName': user.fullName,
      });
      state = state.copyWith(jobs: [job, ...state.jobs]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> applyToJob(
      int jobId, String coverLetter, String resumeUrl) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      await ref.read(jobDatasourceProvider).applyToJob(jobId, {
        'jobId': jobId,
        'userId': user.id,
        'applicantName': user.fullName,
        'coverLetter': coverLetter,
        'resumeUrl': resumeUrl,
        'status': 'PENDING',
      });
      return true;
    } catch (_) {
      return false;
    }
  }
}

final jobsProvider =
    NotifierProvider<JobsNotifier, JobsState>(JobsNotifier.new);

final singleJobProvider = FutureProvider.family<JobModel, int>((ref, id) {
  return ref.watch(jobDatasourceProvider).getJobById(id);
});

final userApplicationsProvider =
    FutureProvider<List<JobApplicationModel>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return ref.watch(jobDatasourceProvider).getApplicationsByUser(user.id);
});
