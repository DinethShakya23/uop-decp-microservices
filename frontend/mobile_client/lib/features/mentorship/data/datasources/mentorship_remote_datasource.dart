import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/mentorship_models.dart';

abstract class MentorshipRemoteDatasource {
  Future<MentorshipProfileModel> getProfile();
  Future<MentorshipProfileModel> saveProfile(Map<String, dynamic> data);
  Future<List<MatchModel>> getMatches();
  Future<List<MentorshipRequestModel>> getRequests();
  Future<void> sendRequest(Map<String, dynamic> data);
  Future<void> respondRequest(int id, String status);
  Future<List<RelationshipModel>> getRelationships();
}

class MentorshipRemoteDatasourceImpl implements MentorshipRemoteDatasource {
  final Dio _dio;
  MentorshipRemoteDatasourceImpl(this._dio);

  @override
  Future<MentorshipProfileModel> getProfile() async {
    try {
      final resp = await _dio.get('${ApiConstants.mentorship}/profile');
      return MentorshipProfileModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return throw const ServerException('Profile not found');
      _handleError(e);
    }
  }

  @override
  Future<MentorshipProfileModel> saveProfile(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post('${ApiConstants.mentorship}/profile', data: data);
      return MentorshipProfileModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<MatchModel>> getMatches() async {
    try {
      final resp = await _dio.get('${ApiConstants.mentorship}/matches');
      final list = resp.data as List? ?? [];
      return list.map((e) => MatchModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<MentorshipRequestModel>> getRequests() async {
    try {
      final resp = await _dio.get('${ApiConstants.mentorship}/requests');
      final list = resp.data as List? ?? [];
      return list.map((e) => MentorshipRequestModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> sendRequest(Map<String, dynamic> data) async {
    try {
      await _dio.post('${ApiConstants.mentorship}/request', data: data);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> respondRequest(int id, String status) async {
    try {
      await _dio.put('${ApiConstants.mentorship}/request/$id', data: {
        'status': status,
        'rejectionReason': null
      });
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<RelationshipModel>> getRelationships() async {
    try {
      final resp = await _dio.get('${ApiConstants.mentorship}/relationships');
      final list = resp.data as List? ?? [];
      return list.map((e) => RelationshipModel.fromJson(e as Map<String, dynamic>)).toList();
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

final mentorshipDatasourceProvider = Provider<MentorshipRemoteDatasource>((ref) {
  return MentorshipRemoteDatasourceImpl(ref.watch(dioProvider));
});
