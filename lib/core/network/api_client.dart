import 'package:dio/dio.dart';

import '../storage/local_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static late Dio dio;

  static Future<void> init() async {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,

        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),

        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    /// REQUEST INTERCEPTOR
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await LocalStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },

        onError: (DioException e, handler) async {
          /// TOKEN EXPIRED
          if (e.response?.statusCode == 401) {
            await LocalStorage.clear();

            // nanti bisa redirect ke login
          }

          return handler.next(e);
        },
      ),
    );

    /// LOGGING
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  /// GET
  static Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        endpoint,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST
  static Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT
  static Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.put(endpoint, data: data);

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE
  static Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      final response = await dio.delete(endpoint, data: data);

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException e) {
    /// SERVER RESPONSE ERROR
    if (e.response != null) {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'];
      }

      return 'Server error';
    }

    /// CONNECTION ERROR
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';

      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';

      case DioExceptionType.sendTimeout:
        return 'Send timeout';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      default:
        return 'Something went wrong';
    }
  }
}
