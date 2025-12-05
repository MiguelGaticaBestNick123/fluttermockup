import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../services/supabase_service.dart';

abstract class AuthRemoteDataSource {
  Future<String> login(String email, String password);
  Future<void> register(String email, String password, String username);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseService supabaseService;

  AuthRemoteDataSourceImpl({required this.supabaseService});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await supabaseService.signIn(email, password);
      if (response.session != null) {
        return response.session!.accessToken;
      } else {
        throw Exception('Login failed: No session created');
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }

  @override
  Future<void> register(String email, String password, String username) async {
    try {
      await supabaseService.signUp(email, password, username);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}
