import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/local_storage.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>(
  (ref) => AuthNotifier(),
);

class AuthNotifier extends StateNotifier<UserModel?> {
  AuthNotifier() : super(null);

  /// LOGIN
  Future<bool> login({required String email, required String password}) async {
    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      final data = response['data'] as Map<String, dynamic>;

      final token = data['token'] as String;

      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

      await LocalStorage.saveToken(token);

      state = user;

      return true;
    } catch (e) {
      print('LOGIN ERROR: $e');
      rethrow;
    }
  }

  /// REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      final token = response['token'];

      await LocalStorage.saveToken(token);

      final user = UserModel.fromJson(response['user']);

      state = user;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// AUTO LOGIN
  Future<void> loadUser() async {
    try {
      final token = await LocalStorage.getToken();

      if (token == null) return;

      final response = await AuthService.me();

      state = UserModel.fromJson(response);
    } catch (e) {
      await logout();
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    try {
      await AuthService.logout();
    } catch (_) {}

    await LocalStorage.clear();

    print('Token Cleared');

    state = null;

    print('State Null');
  }
}
