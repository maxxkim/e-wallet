// test/unit/withdrawal/withdrawal_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';
import 'package:zippy/domain/state/withdrawal/withdrawal_state.dart';
import 'package:zippy/presentation/bloc/withdrawal/withdrawal_cubit.dart';
import 'withdrawal_cubit_test.mocks.dart';

@GenerateMocks([
  WithdrawalRepository
], customMocks: [
  MockSpec<GoRouter>(
    as: #MockGoRouter2,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late WithdrawalCubit withdrawalCubit;
  late WithdrawalRepository mockWithdrawalRepository;
  late MockGoRouter2 mockRouter;

  setUp(() {
    mockWithdrawalRepository = MockWithdrawalRepository();
    mockRouter = MockGoRouter2();
    withdrawalCubit = WithdrawalCubit(mockWithdrawalRepository);
    when(mockRouter.go(any)).thenAnswer((_) {});
  });

  tearDown(() {
    withdrawalCubit.close();
  });

  group('WithdrawalCubit Tests', () {
    final testProviders = [
      Provider(
        id: 1,
        name: 'Test Provider',
        description: 'Test Description',
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final testWithdrawal = Withdrawal(providerList: testProviders);

    final testWithdrawalInitiate = WithdrawalInitiate(
      status: 'success',
      transactionId: 'test_transaction',
      paymentUrl: 'https://test.com/withdrawal',
      description: 'Test withdrawal',
    );

    test('initial state is WithdrawalStateLoading', () {
      expect(withdrawalCubit.state, isA<WithdrawalStateLoading>());
    });

    blocTest<WithdrawalCubit, WithdrawalState>(
      'loadData emits WithdrawalStateLoaded with providers when successful',
      setUp: () {
        when(mockWithdrawalRepository.getProviders())
            .thenAnswer((_) async => testWithdrawal);
      },
      build: () => withdrawalCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<WithdrawalStateLoaded>().having(
          (state) => state.providers,
          'providers',
          testProviders,
        ),
      ],
      verify: (_) {
        verify(mockWithdrawalRepository.getProviders()).called(1);
      },
    );

    blocTest<WithdrawalCubit, WithdrawalState>(
      'loadData emits WithdrawalStateError when providers fetch fails',
      setUp: () {
        when(mockWithdrawalRepository.getProviders())
            .thenThrow(Exception('Failed to load providers'));
      },
      build: () => withdrawalCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<WithdrawalStateError>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Exception: Failed to load providers',
        ),
      ],
    );

    blocTest<WithdrawalCubit, WithdrawalState>(
      'initializeWithdrawal emits WithdrawalStateInitiated when successful',
      setUp: () {
        when(mockWithdrawalRepository.initiateWithdrawal({'amount': 100}))
            .thenAnswer((_) async => testWithdrawalInitiate);
      },
      build: () => withdrawalCubit,
      act: (cubit) => cubit.initializeWithdrawal({'amount': 100}, mockRouter),
      expect: () => [
        isA<WithdrawalStateInitiated>().having(
          (state) => state.url,
          'url',
          'https://test.com/withdrawal',
        ),
      ],
      verify: (_) {
        verify(mockWithdrawalRepository.initiateWithdrawal({'amount': 100}))
            .called(1);
        verify(mockRouter.go('/dashboard')).called(1);
      },
    );

    blocTest<WithdrawalCubit, WithdrawalState>(
      'initializeWithdrawal emits WithdrawalStateError when initiation fails',
      setUp: () {
        when(mockWithdrawalRepository.initiateWithdrawal({'amount': 100}))
            .thenThrow(Exception('Failed to initiate withdrawal'));
      },
      build: () => withdrawalCubit,
      act: (cubit) => cubit.initializeWithdrawal({'amount': 100}, mockRouter),
      expect: () => [
        isA<WithdrawalStateError>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Exception: Failed to initiate withdrawal',
        ),
      ],
    );
  });
}
