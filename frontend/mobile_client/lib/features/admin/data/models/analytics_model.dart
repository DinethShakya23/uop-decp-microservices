class AnalyticsOverviewModel {
  final int totalUsers;
  final int totalPosts;
  final int totalJobs;
  final int totalEvents;
  final int activeUsersToday;

  const AnalyticsOverviewModel({
    required this.totalUsers,
    required this.totalPosts,
    required this.totalJobs,
    required this.totalEvents,
    required this.activeUsersToday,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      totalUsers: (json['totalUsers'] as num?)?.toInt() ?? 0,
      totalPosts: (json['totalPosts'] as num?)?.toInt() ?? 0,
      totalJobs: (json['totalJobs'] as num?)?.toInt() ?? 0,
      totalEvents: (json['totalEvents'] as num?)?.toInt() ?? 0,
      activeUsersToday: (json['activeUsersToday'] as num?)?.toInt() ?? 0,
    );
  }
}
