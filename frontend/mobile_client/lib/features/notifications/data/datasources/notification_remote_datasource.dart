import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDatasource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<int> getUnreadCount();
  Future<void> deleteNotification(String id);
}

class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final Dio _dio;
  NotificationRemoteDatasourceImpl(this._dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final resp = await _dio.get(ApiConstants.notifications);
      final list = resp.data as List;
      return list.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> markRead(String id) async {
    try {
      await _dio.put('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> markAllRead() async {
    try {
      await _dio.put(ApiConstants.readAllNotifications);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final resp = await _dio.get(ApiConstants.unreadCount);
      return (resp.data['count'] as num).toInt();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _dio.delete('${ApiConstants.notifications}/$id');
    } on DioException catch (e) { _handleError(e); }
  }

  Never _handleError(DioException e) {
    if (e.response?.statusCode == 401) throw const AuthException();
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown) {
      throw const NetworkException();
    }
    throw ServerException(e.response?.data?['message']?.toString() ?? 'Error');
  }
}

final notificationDatasourceProvider = Provider<NotificationRemoteDatasource>((ref) {
  return NotificationRemoteDatasourceImpl(ref.watch(dioProvider));
});
