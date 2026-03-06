class ApiConstants {
  // Base URL - use 10.0.2.2 for Android emulator to reach host machine
  static const String baseUrl = 'http://10.0.2.2:8080/api';
  static const String wsUrl = 'ws://10.0.2.2:8080/ws/chat';

  // Auth
  static const String login = '/auth/login';
  static const String authTest = '/auth/test';
  static const String authValidate = '/auth/validate';

  // Users
  static const String register = '/users/register';
  static const String users = '/users';
  static const String alumni = '/users/alumni';
  static const String userSearch = '/users/search';

  // Posts
  static const String posts = '/posts';

  // Jobs
  static const String jobs = '/jobs';

  // Events
  static const String events = '/events';
  static const String upcomingEvents = '/events/upcoming';

  // Notifications
  static const String notifications = '/notifications';
  static const String readAllNotifications = '/notifications/read-all';
  static const String unreadCount = '/notifications/unread-count';

  // Conversations / Messaging
  static const String conversations = '/conversations';

  // Research
  static const String research = '/research';

  // Mentorship
  static const String mentorship = '/mentorship';
  static const String mentorshipProfile = '/mentorship/profile';
  static const String mentorshipMatches = '/mentorship/matches';
  static const String mentorshipRequest = '/mentorship/request';
  static const String mentorshipRequests = '/mentorship/requests';
  static const String mentorshipRelationships = '/mentorship/relationships';

  // Analytics (Admin only)
  static const String analyticsOverview = '/analytics/overview';
  static const String analyticsUsers = '/analytics/users';
  static const String analyticsPosts = '/analytics/posts';
  static const String analyticsJobs = '/analytics/jobs';
  static const String analyticsEvents = '/analytics/events';
  static const String analyticsResearch = '/analytics/research';
  static const String analyticsMessages = '/analytics/messages';
}
