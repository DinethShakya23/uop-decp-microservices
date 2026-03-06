import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/analytics_remote_datasource.dart';
import '../../data/models/analytics_model.dart';

final analyticsOverviewProvider = FutureProvider<AnalyticsOverviewModel>((ref) async {
  return ref.watch(analyticsDatasourceProvider).getOverview();
});
