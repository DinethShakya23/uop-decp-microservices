import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/job_model.dart';

abstract class JobRemoteDatasource {
  Future<List<JobModel>> getJobs();
  Future<JobModel> getJobById(int id);
  Future<JobModel> createJob(Map<String, dynamic> data);
  Future<void> applyToJob(int jobId, Map<String, dynamic> data);
  Future<List<JobApplicationModel>> getApplicationsByUser(int userId);
  Future<List<JobApplicationModel>> getApplicationsByJob(int jobId);
}

class JobRemoteDatasourceImpl implements JobRemoteDatasource {
  final Dio _dio;
  JobRemoteDatasourceImpl(this._dio);

  @override
  Future<List<JobModel>> getJobs() async {
    try {
      final resp = await _dio.get(ApiConstants.jobs);
      final list = resp.data as List;
      return list.map((e) => JobModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<JobModel> getJobById(int id) async {
    try {
      final resp = await _dio.get('${ApiConstants.jobs}/$id');
      return JobModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<JobModel> createJob(Map<String, dynamic> data) async {
    try {
      final resp = await _dio.post(ApiConstants.jobs, data: data);
      return JobModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<void> applyToJob(int jobId, Map<String, dynamic> data) async {
    try {
      await _dio.post('${ApiConstants.jobs}/$jobId/apply', data: data);
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<JobApplicationModel>> getApplicationsByUser(int userId) async {
    try {
      final resp = await _dio.get('${ApiConstants.jobs}/user/$userId/applications');
      final list = resp.data as List;
      return list.map((e) => JobApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) { _handleError(e); }
  }

  @override
  Future<List<JobApplicationModel>> getApplicationsByJob(int jobId) async {
    try {
      final resp = await _dio.get('${ApiConstants.jobs}/$jobId/applications');
      final list = resp.data as List;
      return list.map((e) => JobApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
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

final jobDatasourceProvider = Provider<JobRemoteDatasource>((ref) {
  return JobRemoteDatasourceImpl(ref.watch(dioProvider));
});
