import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';

import '../../shared/widgets/app_shell.dart';

// Posts
import '../../features/posts/presentation/screens/posts_screen.dart';

// Jobs
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/jobs/presentation/screens/job_detail_screen.dart';
import '../../features/jobs/presentation/screens/apply_job_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';

// Events
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';

// Notifications
import '../../features/notifications/presentation/screens/notifications_screen.dart';

// Profile/More
import '../../features/profile/presentation/screens/profile_screen.dart';

// Messaging
import '../../features/messaging/presentation/screens/conversations_screen.dart';
import '../../features/messaging/presentation/screens/chat_screen.dart';

// Research
import '../../features/research/presentation/screens/research_screen.dart';
import '../../features/research/presentation/screens/research_detail_screen.dart';

// Mentorship
import '../../features/mentorship/presentation/screens/mentorship_screen.dart';

// Admin
import '../../features/admin/presentation/screens/analytics_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(authProvider).status;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authStatus == AuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (!isAuth && !isLoginRoute) {
        return '/login';
      }
      if (isAuth && isLoginRoute) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // The ShellRoute handles the bottom navigation bar
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 - Feed
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const PostsScreen(),
              ),
            ],
          ),
          // Branch 1 - Jobs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const JobsScreen(),
              ),
            ],
          ),
          // Branch 2 - Events
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/events',
                builder: (context, state) => const EventsScreen(),
              ),
            ],
          ),
          // Branch 3 - Notifications (Alerts)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => const NotificationsScreen(),
              ),
            ],
          ),
          // Branch 4 - More (Grid Menu)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) => const MoreMenuScreen(),
              ),
            ],
          ),
        ],
      ),

      // Features outside the bottom nav shell (pushed on top)
      // Jobs details
      GoRoute(
        path: '/jobs/create',
        builder: (context, state) => const CreateJobScreen(),
      ),
      GoRoute(
        path: '/jobs/:id',
        builder: (context, state) => JobDetailScreen(jobId: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/jobs/:id/apply',
        builder: (context, state) => ApplyJobScreen(jobId: int.parse(state.pathParameters['id']!)),
      ),

      // Events details
      GoRoute(
        path: '/events/create',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Create Event Stub'))), // Stub for brevity
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) => EventDetailScreen(eventId: int.parse(state.pathParameters['id']!)),
      ),

      // Profile
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Messaging
      GoRoute(
        path: '/conversations',
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) => ChatScreen(conversationId: state.pathParameters['id']!),
      ),

      // Research
      GoRoute(
        path: '/research',
        builder: (context, state) => const ResearchScreen(),
      ),
      GoRoute(
        path: '/research/create',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Create Research Stub'))), // Stub for brevity
      ),
      GoRoute(
        path: '/research/:id',
        builder: (context, state) => ResearchDetailScreen(researchId: int.parse(state.pathParameters['id']!)),
      ),

      // Mentorship
      GoRoute(
        path: '/mentorship',
        builder: (context, state) => const MentorshipScreen(),
      ),

      // Admin
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
    ],
  );
});
