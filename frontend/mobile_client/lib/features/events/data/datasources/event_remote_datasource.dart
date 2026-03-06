import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/event_model.dart';

abstract class EventRemoteDatasource {
  Future<List<EventModel>> getEvents();
  Future<List<EventModel>> getUpcomingEvents();
  Future<EventModel> getEventById(int id);
  Future<EventModel> createEvent(Map<String, dynamic> data);
  Future<EventModel> updateEvent(int id, Map<String, dynamic> data);
  Future<void> deleteEvent(int id);
  Future<RsvpModel> rsvpEvent(int id, String status);
  Future<List<RsvpModel>> getAttendees(int id);
}

class EventRemoteDatasourceImpl implements EventRemoteDatasource {
  final Dio _dio;
  EventRemoteDatasourceImpl(this._dio);

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final resp = await _dio.get(ApiConstants.events);
      final list = resp.data as List;
      return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final resp = await _dio.get(ApiConstants.upcomingEvents);
      final list = resp.data as List;
      return list.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<EventModel> getEventById(int id) async {
    try {
      final resp = await _dio.get('${ApiConstants.events}/$id');
      return EventModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<EventModel> createEvent(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiConstants.events, data: data);
      return EventModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<EventModel> updateEvent(int id, Map<String, dynamic> data) async {
    try {
      final resp = await _dio.put('${ApiConstants.events}/$id', data: data);
      return EventModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> deleteEvent(int id) async {
    try {
      await _dio.delete('${ApiConstants.events}/$id');
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<RsvpModel> rsvpEvent(int id, String status) async {
    try {
      final resp = await _dio.post('${ApiConstants.events}/$id/rsvp',
          data: {'status': status});
      return RsvpModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<RsvpModel>> getAttendees(int id) async {
    try {
      final resp = await _dio.get('${ApiConstants.events}/$id/attendees');
      final list = resp.data as List;
      return list.map((e) => RsvpModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  Never _handleError(DioException e) {
    if (e.response?.statusCode == 401) throw const AuthException();
    if (e.response?.statusCode == 403) throw const ForbiddenException();
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown) {
      throw const NetworkException();
    }
    throw ServerException(e.response?.data?['message']?.toString() ?? 'Error');
  }
}

final eventDatasourceProvider = Provider<EventRemoteDatasource>((ref) {
  return EventRemoteDatasourceImpl(ref.watch(dioProvider));
});
