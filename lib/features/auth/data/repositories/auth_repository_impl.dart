import '../../../../services/auth_service.dart';
import '../../../../services/supabase_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthService localAuthService;
  final SupabaseService supabaseService; // Add SupabaseService

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localAuthService,
    required this.supabaseService,
  });

  @override
  Future<void> login(String username, String password) async {
    // Note: username here is treated as email for Supabase, or we need to handle username login via edge function or email lookup.
    // For simplicity, we assume the user enters Email in the "Username" field or we change the UI to say "Email".
    // Supabase Auth uses Email by default.
    final token = await remoteDataSource.login(username, password);
    await localAuthService.saveToken(token);
  }

  @override
  Future<void> register(String username, String password) async {
    // Same here, username should be email.
    // We might need to ask the user for Email in the UI.
    // For now, let's assume the username field contains an email.
    await remoteDataSource.register(username, password, username);
  }

  @override
  Future<void> logout() async {
    await supabaseService.signOut();
    await localAuthService.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    // Check Supabase session first
    final user = supabaseService.currentUser;
    return user != null;
  }
}
