import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/presentation/bloc/locale/locale_cubit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocaleCubit localeCubit;

  group('LocaleCubit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      localeCubit = LocaleCubit();
    });

    tearDown(() {
      localeCubit.close();
    });

    test('initial state is english locale', () {
      expect(localeCubit.state, equals(const Locale('en')));
    });

    blocTest<LocaleCubit, Locale>(
      'emits spanish locale when changed to spanish',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return LocaleCubit();
      },
      act: (cubit) => cubit.changeLocale(const Locale('es')),
      expect: () => [const Locale('es')],
    );

    blocTest<LocaleCubit, Locale>(
      'emits english locale when changed to english',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return LocaleCubit();
      },
      seed: () => const Locale('es'),
      act: (cubit) => cubit.changeLocale(const Locale('en')),
      expect: () => [const Locale('en')],
    );

    test('loads saved locale from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'selected_locale': 'es'});
      final cubit = LocaleCubit();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state, equals(const Locale('es')));
      cubit.close();
    });

    test('saves locale to SharedPreferences when changed', () async {
      SharedPreferences.setMockInitialValues({});
      await localeCubit.changeLocale(const Locale('es'));

      final prefs = await SharedPreferences.getInstance();
      final savedLocale = prefs.getString('selected_locale');
      expect(savedLocale, equals('es'));
    });

    test('handles invalid saved locale gracefully', () async {
      SharedPreferences.setMockInitialValues(
          {'selected_locale': 'invalid_locale'});
      final cubit = LocaleCubit();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(cubit.state.languageCode, equals('en'));
      cubit.close();
    });

    blocTest<LocaleCubit, Locale>(
      'transitions between multiple locale changes',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return LocaleCubit();
      },
      act: (cubit) async {
        await cubit.changeLocale(const Locale('es'));
        await cubit.changeLocale(const Locale('en'));
        await cubit.changeLocale(const Locale('es'));
      },
      expect: () => [
        const Locale('es'),
        const Locale('en'),
        const Locale('es'),
      ],
    );
  });
}
