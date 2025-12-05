import 'package:dio/dio.dart';
import '../../../../services/api_service.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String username, String password);
  Future<void> register(String username, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl({required this.apiService});

  @override
  Future<String> login(String username, String password) async {
    try {
      final response = await apiService.login(username, password);
      if (response.statusCode == 200) {
        return response.data['access_token'];
      } else {
        throw Exception('Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> register(String username, String password) async {
    final response = await apiService.dio.post('/register', data: {
      'username': username,
      'password': password,
    });
    if (response.statusCode != 201) {
      throw Exception('Registration failed');
    }
  }
}
