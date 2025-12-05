import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_event.dart';
import 'package:fluttermockup/features/auth/presentation/bloc/auth_state.dart';
import 'package:fluttermockup/features/auth/presentation/pages/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  group('LoginPage', () {
    late AuthBloc authBloc;

    setUp(() {
      authBloc = MockAuthBloc();
    });

    testWidgets('renders login form', (tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const LoginPage(),
          ),
        ),
      );

      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('adds AuthLoginRequested when login button is pressed', (tester) async {
      when(() => authBloc.state).thenReturn(AuthInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: authBloc,
            child: const LoginPage(),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).first, 'user');
      await tester.enterText(find.byType(TextFormField).last, 'pass');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      verify(() => authBloc.add(const AuthLoginRequested('user', 'pass'))).called(1);
    });
  });
}
