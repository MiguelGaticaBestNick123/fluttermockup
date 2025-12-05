import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:prueba/core/presentation/bloc/theme_cubit.dart';

void main() {
  group('ThemeCubit', () {
    late ThemeCubit themeCubit;

    setUp(() {
      themeCubit = ThemeCubit();
    });

    tearDown(() {
      themeCubit.close();
    });

    test('initial state is ThemeMode.light', () {
      expect(themeCubit.state, ThemeMode.light);
    });

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.dark] when toggleTheme is called',
      build: () => themeCubit,
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [ThemeMode.dark],
    );

    blocTest<ThemeCubit, ThemeMode>(
      'emits [ThemeMode.dark, ThemeMode.light] when toggleTheme is called twice',
      build: () => themeCubit,
      act: (cubit) {
        cubit.toggleTheme();
        cubit.toggleTheme();
      },
      expect: () => [ThemeMode.dark, ThemeMode.light],
    );
  });
}
