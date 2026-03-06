import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/post_model.dart';

abstract class PostRemoteDatasource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> createPost({
    required int userId,
    required String fullName,
    required String content,
    List<String> mediaUrls,
  });
  Future<void> likePost(String postId, int userId);
  Future<void> commentPost(
      String postId, int userId, String username, String text);
}

class PostRemoteDatasourceImpl implements PostRemoteDatasource {
  final Dio _dio;
  PostRemoteDatasourceImpl(this._dio);

  @override
  Future<List<PostModel>> getPosts() async {
    try {
      final resp = await _dio.get(ApiConstants.posts);
      final list = resp.data as List;
      return list.map((e) => PostModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<PostModel> createPost({
    required int userId,
    required String fullName,
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    try {
      final resp = await _dio.post(ApiConstants.posts, data: {
        'userId': userId,
        'fullName': fullName,
        'content': content,
        'mediaUrls': mediaUrls,
      });
      return PostModel.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> likePost(String postId, int userId) async {
    try {
      await _dio.post('${ApiConstants.posts}/$postId/like',
          data: {'userId': userId});
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<void> commentPost(
      String postId, int userId, String username, String text) async {
    try {
      await _dio.post('${ApiConstants.posts}/$postId/comment', data: {
        'userId': userId,
        'username': username,
        'text': text,
      });
    } on DioException catch (e) {
      _handleError(e);
    }
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

final postDatasourceProvider = Provider<PostRemoteDatasource>((ref) {
  return PostRemoteDatasourceImpl(ref.watch(dioProvider));
});
