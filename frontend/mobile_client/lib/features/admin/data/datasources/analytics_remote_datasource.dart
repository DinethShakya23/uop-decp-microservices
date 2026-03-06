import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDatasource {
  Future<AnalyticsOverviewModel> getOverview();
}

class AnalyticsRemoteDatasourceImpl implements AnalyticsRemoteDatasource {
  final Dio _dio;
  AnalyticsRemoteDatasourceImpl(this._dio);

  @override
  Future<AnalyticsOverviewModel> getOverview() async {
    try {
      final resp = await _dio.get('${ApiConstants.baseUrl}/analytics/overview');
      return AnalyticsOverviewModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) throw const AuthException();
      if (e.response?.statusCode == 403) throw const ForbiddenException();
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.unknown) {
        throw const NetworkException();
      }
      throw ServerException(e.response?.data?['message']?.toString() ?? 'Error');
    }
  }
}

final analyticsDatasourceProvider = Provider<AnalyticsRemoteDatasource>((ref) {
  return AnalyticsRemoteDatasourceImpl(ref.watch(dioProvider));
});
