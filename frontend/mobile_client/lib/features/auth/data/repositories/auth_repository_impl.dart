import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;
  final SecureStorageService _storage;

  static const _userKey = 'current_user';

  AuthRepositoryImpl(this._datasource, this._storage);

  @override
  Future<({String token, UserModel user})> login(
      String username, String password) async {
    final result = await _datasource.login(username, password);
    await _storage.saveToken(result.token);
    await _storage.saveData(_userKey, jsonEncode(result.user.toJson()));
    return (token: result.token, user: result.user);
  }

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    return _datasource.register(
      username: username,
      email: email,
      password: password,
      fullName: fullName,
      role: role,
    );
  }

  @override
  Future<void> logout() async {
    await _storage.deleteToken();
    await _storage.deleteData(_userKey);
  }

  @override
  Future<String?> getStoredToken() => _storage.readToken();

  @override
  Future<UserModel?> getStoredUser() async {
    final raw = await _storage.readData(_userKey);
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDatasourceProvider),
    ref.watch(secureStorageProvider),
  );
});
