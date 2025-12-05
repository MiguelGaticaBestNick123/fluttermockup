import '../../../../services/auth_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthService localAuthService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localAuthService,
  });

  @override
  Future<void> login(String username, String password) async {
    final token = await remoteDataSource.login(username, password);
    await localAuthService.saveToken(token);
  }

  @override
  Future<void> register(String username, String password) async {
    await remoteDataSource.register(username, password);
  }

  @override
  Future<void> logout() async {
    await localAuthService.deleteToken();
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localAuthService.isLoggedIn();
  }
}
