import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fluttermockup/features/auth/domain/repositories/auth_repository.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_event.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  group('AuthBloc', () {
    late AuthRepository authRepository;

    setUp(() {
      authRepository = MockAuthRepository();
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => authRepository.login(any(), any()))
            .thenAnswer((_) async {});
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested('user', 'pass')),
      expect: () => [AuthLoading(), AuthAuthenticated()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () {
        when(() => authRepository.login(any(), any()))
            .thenThrow(Exception('Login failed'));
        return AuthBloc(authRepository: authRepository);
      },
      act: (bloc) => bloc.add(const AuthLoginRequested('user', 'pass')),
      expect: () => [AuthLoading(), const AuthFailure('Exception: Login failed')],
    );
  });
}
