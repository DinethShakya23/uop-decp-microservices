import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../../data/models/event_model.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => ref.read(eventsProvider.notifier).loadEvents());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsProvider);
    final user = ref.watch(currentUserProvider);
    final canCreate = user?.role == 'ALUMNI' || user?.role == 'ADMIN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'All Events'), Tab(text: 'Upcoming')],
        ),
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton(
              onPressed: () => context.push('/events/create'),
              child: const Icon(Icons.add))
          : null,
      body: Builder(builder: (_) {
        if (state.isLoading && state.events.isEmpty) {
          return const AppLoadingWidget(message: 'Loading events...');
        }
        if (state.error != null && state.events.isEmpty) {
          return AppErrorWidget(message: state.error!,
              onRetry: () => ref.read(eventsProvider.notifier).loadEvents());
        }
        final now = DateTime.now();
        final upcoming = state.events.where((e) {
          try {
            return DateTime.parse(e.eventDate).isAfter(now);
          } catch (_) { return true; }
        }).toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _EventList(events: state.events),
            _EventList(events: upcoming),
          ],
        );
      }),
    );
  }
}

class _EventList extends ConsumerWidget {
  final List<EventModel> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (events.isEmpty) {
      return const Center(child: Text('No events available.'));
    }
    return RefreshIndicator(
      onRefresh: () => ref.read(eventsProvider.notifier).loadEvents(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: events.length,
        itemBuilder: (_, i) => _EventCard(event: events[i]),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  Color _categoryColor() {
    switch (event.category) {
      case 'WORKSHOP': return const Color(0xFF1565C0);
      case 'SEMINAR': return const Color(0xFF6A1B9A);
      case 'CAREER_FAIR': return const Color(0xFF00897B);
      case 'SOCIAL': return const Color(0xFFF57C00);
      default: return const Color(0xFF546E7A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/events/${event.id}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(event.title, style: Theme.of(context).textTheme.titleMedium)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _categoryColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(event.category,
                      style: TextStyle(color: _categoryColor(), fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text(formatDate(event.eventDate), style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Text('${formatTime(event.startTime)} – ${formatTime(event.endTime)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF9E9E9E)),
                const SizedBox(width: 4),
                Expanded(child: Text(event.location, style: Theme.of(context).textTheme.bodySmall)),
              ]),
              if ((event.attendeeCount ?? 0) > 0) ...[
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.people_outlined, size: 14, color: Color(0xFF9E9E9E)),
                  const SizedBox(width: 4),
                  Text('${event.attendeeCount} / ${event.maxAttendees} attendees',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
