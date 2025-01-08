import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';

void main() {
  late ThemeCubit themeCubit;

  setUp(() {
    themeCubit = ThemeCubit();
  });

  tearDown(() {
    themeCubit.close();
  });

  group('ThemeCubit Tests', () {
    test('initial state is light theme', () {
      expect(themeCubit.state, equals(AppTheme.light));
    });

    blocTest<ThemeCubit, AppTheme>(
      'toggleTheme changes from light to dark theme',
      build: () => ThemeCubit(),
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [AppTheme.dark],
    );

    blocTest<ThemeCubit, AppTheme>(
      'toggleTheme changes from dark to light theme',
      build: () => ThemeCubit(),
      seed: () => AppTheme.dark,
      act: (cubit) => cubit.toggleTheme(),
      expect: () => [AppTheme.light],
    );

    test('isDarkMode returns true when theme is dark', () {
      themeCubit.toggleTheme(); // Switch to dark theme
      expect(themeCubit.isDarkMode, isTrue);
    });

    test('isDarkMode returns false when theme is light', () {
      expect(themeCubit.isDarkMode, isFalse);
    });

    blocTest<ThemeCubit, AppTheme>(
      'multiple theme toggles emit correct states',
      build: () => ThemeCubit(),
      act: (cubit) async {
        cubit.toggleTheme(); // light -> dark
        cubit.toggleTheme(); // dark -> light
        cubit.toggleTheme(); // light -> dark
      },
      expect: () => [
        AppTheme.dark,
        AppTheme.light,
        AppTheme.dark,
      ],
    );

    test('theme toggle updates isDarkMode correctly', () {
      expect(themeCubit.isDarkMode, isFalse); // Initial state

      themeCubit.toggleTheme();
      expect(themeCubit.isDarkMode, isTrue);

      themeCubit.toggleTheme();
      expect(themeCubit.isDarkMode, isFalse);
    });
  });
}
