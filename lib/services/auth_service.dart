import '../core/network/api_client.dart';

class AuthService {
  /// LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/login',
      data: {'email': email, 'password': password},
    );

    return response.data;
  }

  /// REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/register',
      data: {'name': name, 'email': email, 'password': password},
    );

    return response.data;
  }

  /// GET PROFILE
  static Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.get('/me');

    return response.data;
  }

  /// LOGOUT
  static Future logout() async {
    await ApiClient.post('/logout');
  }
}
