import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/events_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/date_utils.dart';

class EventDetailScreen extends ConsumerWidget {
  final int eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(singleEventProvider(eventId));
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: eventAsync.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(message: e.toString()),
        data: (event) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(event.category,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 12),
                      Text(event.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      if (event.organizerName != null)
                        Text('by ${event.organizerName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Info
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _InfoRow(Icons.calendar_today_outlined, formatDate(event.eventDate)),
                        const Divider(),
                        _InfoRow(Icons.access_time_outlined,
                            '${formatTime(event.startTime)} – ${formatTime(event.endTime)}'),
                        const Divider(),
                        _InfoRow(Icons.location_on_outlined, event.location),
                        const Divider(),
                        _InfoRow(Icons.people_outlined,
                            '${event.attendeeCount ?? 0} / ${event.maxAttendees} attending'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text('About', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(event.description,
                        style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ),
                const SizedBox(height: 24),

                // RSVP buttons
                Text('Your RSVP', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _RsvpButton(
                      label: 'Going',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF00897B),
                      onTap: () async {
                        final ok = await ref.read(eventsProvider.notifier).rsvpEvent(event.id!, 'GOING');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(ok ? 'RSVP: Going!' : 'Failed to RSVP')));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RsvpButton(
                      label: 'Maybe',
                      icon: Icons.help_outline,
                      color: const Color(0xFFF57C00),
                      onTap: () async {
                        await ref.read(eventsProvider.notifier).rsvpEvent(event.id!, 'MAYBE');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _RsvpButton(
                      label: "Can't Go",
                      icon: Icons.cancel_outlined,
                      color: const Color(0xFFD32F2F),
                      onTap: () async {
                        await ref.read(eventsProvider.notifier).rsvpEvent(event.id!, 'NOT_GOING');
                      },
                    ),
                  ),
                ]),

                // Delete for organizer/admin
                if (user?.id == event.organizer || user?.role == 'ADMIN') ...[
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red)),
                    onPressed: () async {
                      final ok = await ref.read(eventsProvider.notifier).deleteEvent(event.id!);
                      if (ok && context.mounted) context.pop();
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Delete Event'),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ]),
    );
  }
}

class _RsvpButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RsvpButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color),
          minimumSize: const Size(0, 44)),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}
