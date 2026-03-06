import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mentorship_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../core/utils/date_utils.dart';

class MentorshipScreen extends ConsumerStatefulWidget {
  const MentorshipScreen({super.key});

  @override
  ConsumerState<MentorshipScreen> createState() => _MentorshipScreenState();
}

class _MentorshipScreenState extends ConsumerState<MentorshipScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    Future.microtask(() => ref.read(mentorshipProvider.notifier).loadAll());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _showCreateProfile() {
    // Simple dialog for profile creation/update stub
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mentorship Profile'),
        content: const Text(
            'To participate in mentorship, please complete your profile. (UI Stub for brevity)'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final user = ref.read(currentUserProvider);
              ref.read(mentorshipProvider.notifier).saveProfile({
                'role': user?.role == 'STUDENT' ? 'MENTEE' : 'MENTOR',
                'department': 'Computer Science',
                'yearsOfExperience': 2,
                'expertise': ['Flutter', 'Java'],
                'interests': ['Mobile Dev'],
                'bio': 'Looking forward to connecting!',
                'availability': 'AVAILABLE',
                'timezone': 'UTC'
              });
            },
            child: const Text('Auto-fill Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mentorshipProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorship'),
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Requests'),
            Tab(text: 'Active'),
          ],
        ),
      ),
      body: state.when(
        loading: () => const AppLoadingWidget(),
        error: (e, _) => AppErrorWidget(
            message: e.toString(),
            onRetry: () => ref.read(mentorshipProvider.notifier).loadAll()),
        data: (data) {
          if (data.profile == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.handshake_outlined, size: 60, color: Color(0xFFBDBDBD)),
                  const SizedBox(height: 16),
                  const Text('Join the Mentorship Program',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Connect with peers, alumni, and staff.',
                      style: TextStyle(color: Color(0xFF757575))),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showCreateProfile,
                    child: const Text('Set Up Profile'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabCtrl,
            children: [
              // Matches
              RefreshIndicator(
                onRefresh: () => ref.read(mentorshipProvider.notifier).loadAll(),
                child: data.matches.isEmpty
                    ? const Center(child: Text('No recommendations yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: data.matches.length,
                        itemBuilder: (_, i) {
                          final match = data.matches[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1565C0).withValues(alpha: 0.15),
                                child: Text(match.userName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(color: Color(0xFF1565C0))),
                              ),
                              title: Text(match.userName),
                              subtitle: Text(
                                  '${(match.compatibilityScore * 100).toInt()}% Match\n${match.commonInterests.join(", ")}'),
                              isThreeLine: true,
                              trailing: IconButton(
                                icon: const Icon(Icons.person_add_outlined, color: Color(0xFF00897B)),
                                onPressed: () async {
                                  final ok = await ref.read(mentorshipProvider.notifier)
                                      .requestMentor(match.userId, 'Hi, I would love to connect!', []);
                                  if (context.mounted && ok) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Request sent!')));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Requests
              RefreshIndicator(
                onRefresh: () => ref.read(mentorshipProvider.notifier).loadAll(),
                child: data.requests.isEmpty
                    ? const Center(child: Text('No pending requests.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: data.requests.length,
                        itemBuilder: (_, i) {
                          final req = data.requests[i];
                          final isReceived = req.menteeName != ref.read(currentUserProvider)?.username;
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isReceived ? 'From: ${req.menteeName}' : 'To: ${req.mentorName}',
                                      style: Theme.of(context).textTheme.titleMedium),
                                  const SizedBox(height: 4),
                                  Text('Status: ${req.status}',
                                      style: TextStyle(
                                          color: req.status == 'PENDING' ? Colors.orange : Colors.grey,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('"${req.message}"', style: const TextStyle(fontStyle: FontStyle.italic)),
                                  if (isReceived && req.status == 'PENDING') ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => ref.read(mentorshipProvider.notifier).respondRequest(req.id, 'REJECTED'),
                                          child: const Text('Decline', style: TextStyle(color: Colors.red))),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => ref.read(mentorshipProvider.notifier).respondRequest(req.id, 'ACCEPTED'),
                                          child: const Text('Accept')),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Active Relationships
              RefreshIndicator(
                onRefresh: () => ref.read(mentorshipProvider.notifier).loadAll(),
                child: data.relationships.isEmpty
                    ? const Center(child: Text('No active mentorships.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: data.relationships.length,
                        itemBuilder: (_, i) {
                          final rel = data.relationships[i];
                          final otherName = rel.menteeName == ref.read(currentUserProvider)?.username
                              ? rel.mentorName
                              : rel.menteeName;
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFE8F5E9),
                                child: Icon(Icons.handshake_rounded, color: Color(0xFF2E7D32)),
                              ),
                              title: Text(otherName),
                              subtitle: Text('Status: ${rel.status}\nStarted: ${timeAgo(rel.createdAt)}'),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
