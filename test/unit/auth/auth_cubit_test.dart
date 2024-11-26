import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'auth_repository_mock.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  setUp(() async {
    // Set up SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  group('AuthCubit Tests', () {
    const testPhone = '+56912345678';
    const testUserId = 'test-user-id';
    const testCode = '1234';
    const testAccessToken = 'test-token';
    const testRefreshToken = 'test-refresh-token';

    final testAuthVerify = AuthVerify(
      isVerified: true,
      accessToken: testAccessToken,
      refreshToken: testRefreshToken,
    );

    test('initial state is correct', () {
      expect(
        authCubit.state,
        isA<AuthStateLoaded>()
            .having((state) => state.termsAccepted, 'termsAccepted', false)
            .having((state) => state.codeStatus, 'codeStatus', CodeStatus.none)
            .having((state) => state.shakeKey, 'shakeKey', false)
            .having((state) => state.userId, 'userId', '')
            .having((state) => state.phone, 'phone', ''),
      );
    });

    blocTest<AuthCubit, AuthState>(
      'emits correct states when verifyCode is called successfully',
      setUp: () async {
        print('\nSetting up test:');
        // Initialize SharedPreferences for this test
        SharedPreferences.setMockInitialValues({});
      },
      build: () {
        print('\nSetting up mock:');
        when(mockAuthRepository.verifyAuth(testCode, testPhone, testUserId))
            .thenAnswer((_) async {
          print('Mock returning AuthVerify with:');
          print('isVerified: ${testAuthVerify.isVerified}');
          print('accessToken: ${testAuthVerify.accessToken}');
          print('refreshToken: ${testAuthVerify.refreshToken}');
          return testAuthVerify;
        });
        return authCubit;
      },
      seed: () {
        print('\nSetting initial state:');
        final initialState = AuthStateLoaded(
          termsAccepted: false,
          codeStatus: CodeStatus.none,
          shakeKey: false,
          userId: testUserId,
          phone: testPhone,
          authInitiateResponse: AuthInitiate(
            isNewUser: true,
            userId: testUserId,
            walletId: 'test-wallet',
          ),
        );
        print('userId: ${initialState.userId}');
        print('phone: ${initialState.phone}');
        return initialState;
      },
      act: (cubit) async {
        print('\nExecuting verifyCode with: $testCode');
        await cubit.verifyCode(testCode);
      },
      expect: () => [
        isA<AuthStateLoaded>()
            .having(
                (state) => state.codeStatus, 'codeStatus', CodeStatus.correct)
            .having((state) => state.userId, 'userId', testUserId)
            .having((state) => state.phone, 'phone', testPhone)
            .having(
              (state) => state.authVerifyResponse?.isVerified,
              'authVerifyResponse.isVerified',
              true,
            )
            .having(
              (state) => state.authVerifyResponse?.accessToken,
              'authVerifyResponse.accessToken',
              testAccessToken,
            )
            .having(
              (state) => state.authVerifyResponse?.refreshToken,
              'authVerifyResponse.refreshToken',
              testRefreshToken,
            ),
      ],
      verify: (_) {
        verify(mockAuthRepository.verifyAuth(testCode, testPhone, testUserId))
            .called(1);
      },
    );
  });
}
