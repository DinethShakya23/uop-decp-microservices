import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../models/user_model.dart';

class LoginResponse {
  final String token;
  final UserModel user;

  const LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
  if (json['token'] == null || json['user'] == null) {
    throw const ServerException('Invalid login response');
  }

  return LoginResponse(
    token: json['token'] as String,
    user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  );
}
}

abstract class AuthRemoteDatasource {
  Future<LoginResponse> login(String username, String password);
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasourceImpl(this._dio);

  @override
  Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );
      return LoginResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401) throw const AuthException();
    if (statusCode == 409) {
      throw ConflictException(
        e.response?.data?['message'] as String? ?? 'Username or email already exists.');
    }
    if (statusCode == 400) {
      throw ValidationException(
        e.response?.data?['message'] as String? ?? 'Invalid input.');
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown) {
      throw const NetworkException();
    }
    throw ServerException(e.response?.data?['message'] as String? ?? 'Server error.');
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(ref.watch(dioProvider));
});
