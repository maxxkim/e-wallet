import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/session/session_state.dart';
import '../auth/auth_repository_mock.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AuthRepository mockAuthRepository;
  late SessionCubit sessionCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    sessionCubit = SessionCubit(mockAuthRepository); // Initialize here
  });

  tearDown(() async {
    await sessionCubit.close();
  });

  group('SessionCubit Tests', () {
    blocTest<SessionCubit, SessionState>(
      'emits [InitialLoading, Unauthenticated] when no token exists',
      setUp: () async {
        SharedPreferences.setMockInitialValues({});
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [
        isA<InitialLoading>(),
        isA<Unauthenticated>(),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [InitialLoading, Authenticated] when valid token exists',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'accessToken': 'valid_token',
        });
        when(mockAuthRepository.verifyToken('valid_token'))
            .thenAnswer((_) async => true);
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [
        isA<InitialLoading>(),
        isA<Authenticated>().having(
          (state) => state.accessToken,
          'accessToken',
          'valid_token',
        ),
      ],
    );

    blocTest<SessionCubit, SessionState>(
      'emits [InitialLoading, Unauthenticated] when token is invalid',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'accessToken': 'invalid_token',
        });
        when(mockAuthRepository.verifyToken('invalid_token'))
            .thenAnswer((_) async => false);
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [
        isA<InitialLoading>(),
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.verifyToken('invalid_token')).called(1);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'emits [InitialLoading, Unauthenticated] when token verification throws',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'accessToken': 'error_token',
        });
        when(mockAuthRepository.verifyToken('error_token'))
            .thenThrow(Exception('Token verification failed'));
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [
        isA<InitialLoading>(),
        isA<Unauthenticated>(),
      ],
      verify: (_) {
        verify(mockAuthRepository.verifyToken('error_token')).called(1);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'logout clears tokens and emits Unauthenticated',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'accessToken': 'valid_token',
          'refreshToken': 'refresh_token',
        });
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.logout(),
      expect: () => [isA<Unauthenticated>()],
      verify: (_) async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('accessToken'), isNull);
        expect(prefs.getString('refreshToken'), isNull);
      },
    );

    blocTest<SessionCubit, SessionState>(
      'checkAuthentication refreshes state correctly',
      setUp: () async {
        SharedPreferences.setMockInitialValues({
          'accessToken': 'new_token',
        });
        when(mockAuthRepository.verifyToken('new_token'))
            .thenAnswer((_) async => true);
      },
      build: () => sessionCubit,
      act: (cubit) => cubit.checkAuthentication(),
      expect: () => [
        isA<InitialLoading>(),
        isA<Authenticated>().having(
          (state) => state.accessToken,
          'accessToken',
          'new_token',
        ),
      ],
    );

    test('timer is cancelled on close', () async {
      final cubit =
          SessionCubit(mockAuthRepository); // Create separate instance
      await cubit.close();
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
