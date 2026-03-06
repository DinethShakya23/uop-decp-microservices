import 'package:decp_mobile_app/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<({String token, UserModel user})> login(String username, String password);
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    required String role,
  });
  Future<void> logout();
  Future<String?> getStoredToken();
  Future<UserModel?> getStoredUser();
}
