import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/event_remote_datasource.dart';
import '../../data/models/event_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EventsState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;

  const EventsState(
      {this.events = const [], this.isLoading = false, this.error});

  EventsState copyWith(
          {List<EventModel>? events,
          bool? isLoading,
          String? error,
          bool clearError = false}) =>
      EventsState(
        events: events ?? this.events,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class EventsNotifier extends Notifier<EventsState> {
  @override
  EventsState build() {
    _init();
    return const EventsState();
  }

  Future<void> _init() async {
    await loadEvents();
  }

  Future<void> loadEvents({bool upcomingOnly = false}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ds = ref.read(eventDatasourceProvider);
      final events =
          upcomingOnly ? await ds.getUpcomingEvents() : await ds.getEvents();
      state = state.copyWith(events: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String location,
    required String eventDate,
    required String startTime,
    required String endTime,
    required String category,
    required int maxAttendees,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return false;
    try {
      final event = await ref.read(eventDatasourceProvider).createEvent({
        'title': title,
        'description': description,
        'location': location,
        'eventDate': eventDate,
        'startTime': startTime,
        'endTime': endTime,
        'category': category,
        'maxAttendees': maxAttendees,
      });
      state = state.copyWith(events: [event, ...state.events]);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rsvpEvent(int eventId, String status) async {
    try {
      await ref.read(eventDatasourceProvider).rsvpEvent(eventId, status);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEvent(int eventId) async {
    try {
      await ref.read(eventDatasourceProvider).deleteEvent(eventId);
      state = state.copyWith(
          events: state.events.where((e) => e.id != eventId).toList());
      return true;
    } catch (_) {
      return false;
    }
  }
}

final eventsProvider =
    NotifierProvider<EventsNotifier, EventsState>(EventsNotifier.new);

final singleEventProvider = FutureProvider.family<EventModel, int>((ref, id) {
  return ref.watch(eventDatasourceProvider).getEventById(id);
});

final eventAttendeesProvider =
    FutureProvider.family<List<RsvpModel>, int>((ref, eventId) {
  return ref.watch(eventDatasourceProvider).getAttendees(eventId);
});
