import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/session/session_state.dart';

import 'session_cubit_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionCubit sessionCubit;
  late AuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    sessionCubit.close();
  });

  group('SessionCubit Tests', () {
    test('initial state is InitialLoading', () {
      sessionCubit = SessionCubit(mockAuthRepository);
      expect(sessionCubit.state, isA<InitialLoading>());
    });

    blocTest<SessionCubit, SessionState>(
      'emits [InitialLoading, Unauthenticated] when no token exists',
      build: () {
        SharedPreferences.setMockInitialValues({});
        return SessionCubit(mockAuthRepository);
      },
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
      build: () => SessionCubit(mockAuthRepository),
      expect: () => [
        isA<InitialLoading>(),
        isA<Authenticated>().having(
          (state) => state.accessToken,
          'accessToken',
          'valid_token',
        ),
      ],
      verify: (_) {
        verify(mockAuthRepository.verifyToken('valid_token')).called(1);
      },
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
      build: () => SessionCubit(mockAuthRepository),
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
      build: () => SessionCubit(mockAuthRepository),
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
        when(mockAuthRepository.verifyToken('valid_token'))
            .thenAnswer((_) async => true);
      },
      build: () => SessionCubit(mockAuthRepository),
      act: (cubit) => cubit.logout(),
      skip: 2, // Skip initial states
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
      build: () => SessionCubit(mockAuthRepository),
      act: (cubit) => cubit.checkAuthentication(),
      skip: 2, // Skip initial states
      expect: () => [
        isA<Authenticated>().having(
          (state) => state.accessToken,
          'accessToken',
          'new_token',
        ),
      ],
    );

    test('timer is cancelled on close', () async {
      sessionCubit = SessionCubit(mockAuthRepository);
      await sessionCubit.close();
      // Verify no more interactions with repository after close
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
