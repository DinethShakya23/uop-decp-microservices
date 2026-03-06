import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/mentorship_remote_datasource.dart';
import '../../data/models/mentorship_models.dart';

class MentorshipProviderNotifier extends Notifier<AsyncValue<MentorshipData>> {
  @override
  AsyncValue<MentorshipData> build() {
    // Load initial data
    Future.microtask(loadAll);
    return const AsyncLoading();
  }

  Future<void> loadAll() async {
    state = const AsyncLoading();
    try {
      final ds = ref.read(mentorshipDatasourceProvider);
      
      MentorshipProfileModel? profile;
      try {
        profile = await ds.getProfile();
      } catch (e) {
        // 404 means no profile yet, ignore
      }

      var matches = <MatchModel>[];
      if (profile != null) {
        matches = await ds.getMatches();
      }

      final requests = await ds.getRequests();
      final relationships = await ds.getRelationships();

      state = AsyncData(MentorshipData(
        profile: profile,
        matches: matches,
        requests: requests,
        relationships: relationships,
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<bool> saveProfile(Map<String, dynamic> data) async {
    try {
      await ref.read(mentorshipDatasourceProvider).saveProfile(data);
      loadAll();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> requestMentor(int mentorId, String message, List<String> topics) async {
    try {
      await ref.read(mentorshipDatasourceProvider).sendRequest({
        'mentorId': mentorId,
        'message': message,
        'topics': topics,
        'proposedDuration': 'THREE_MONTHS'
      });
      loadAll();
      return true;
    } catch (_) { return false; }
  }

  Future<bool> respondRequest(int id, String status) async {
    try {
      await ref.read(mentorshipDatasourceProvider).respondRequest(id, status);
      loadAll();
      return true;
    } catch (_) { return false; }
  }
}

class MentorshipData {
  final MentorshipProfileModel? profile;
  final List<MatchModel> matches;
  final List<MentorshipRequestModel> requests;
  final List<RelationshipModel> relationships;

  const MentorshipData({
    this.profile,
    required this.matches,
    required this.requests,
    required this.relationships,
  });
}

final mentorshipProvider = NotifierProvider<MentorshipProviderNotifier, AsyncValue<MentorshipData>>(MentorshipProviderNotifier.new);
