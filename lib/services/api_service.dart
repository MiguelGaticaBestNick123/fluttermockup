import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  final Dio _dio = Dio();
  final AuthService _authService = AuthService();
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiration or invalid token
          // For now, we might just want to let the UI handle it or logout
          _authService.deleteToken();
        }
        return handler.next(e);
      },
    ));
  }

  Dio get dio => _dio;

  Future<Response> login(String username, String password) async {
    return await _dio.post('/login', data: {
      'username': username,
      'password': password,
    });
  }
}
