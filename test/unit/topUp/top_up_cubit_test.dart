// test/unit/topUp/top_up_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/domain/state/topUp/top_up_state.dart';
import 'package:zippy/presentation/bloc/topUp/top_up_cubit.dart';
import 'top_up_cubit_test.mocks.dart';

@GenerateMocks([
  TopUpRepository
], customMocks: [
  MockSpec<GoRouter>(
    as: #MockGoRouter3,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late TopUpCubit topUpCubit;
  late TopUpRepository mockTopUpRepository;
  late MockGoRouter3 mockRouter;

  setUp(() {
    mockTopUpRepository = MockTopUpRepository();
    mockRouter = MockGoRouter3();
    topUpCubit = TopUpCubit(mockTopUpRepository);
    when(mockRouter.go(any)).thenAnswer((_) {});
  });

  tearDown(() {
    topUpCubit.close();
  });

  group('TopUpCubit Tests', () {
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

    final testTopUp = TopUp(providerList: testProviders);

    final testTopUpInitiate = TopUpInitiate(
      status: 'success',
      transactionId: 'test_transaction',
      paymentUrl: 'https://test.com/payment',
      description: 'Test top-up',
    );

    test('initial state is TopUpStateLoading', () {
      expect(topUpCubit.state, isA<TopUpStateLoading>());
    });

    blocTest<TopUpCubit, TopUpState>(
      'loadData emits TopUpStateLoaded with providers when successful',
      setUp: () {
        when(mockTopUpRepository.getProviders())
            .thenAnswer((_) async => testTopUp);
      },
      build: () => topUpCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<TopUpStateLoaded>().having(
          (state) => state.providers,
          'providers',
          testProviders,
        ),
      ],
      verify: (_) {
        verify(mockTopUpRepository.getProviders()).called(1);
      },
    );

    blocTest<TopUpCubit, TopUpState>(
      'loadData emits TopUpStateError when providers fetch fails',
      setUp: () {
        when(mockTopUpRepository.getProviders())
            .thenThrow(Exception('Failed to load providers'));
      },
      build: () => topUpCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<TopUpStateError>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Exception: Failed to load providers',
        ),
      ],
    );

    blocTest<TopUpCubit, TopUpState>(
      'initializeTopUp emits TopUpStateInitiated when successful',
      setUp: () {
        when(mockTopUpRepository.initiateTopUp({'amount': 100}))
            .thenAnswer((_) async => testTopUpInitiate);
      },
      build: () => topUpCubit,
      act: (cubit) => cubit.initializeTopUp({'amount': 100}, mockRouter),
      expect: () => [
        isA<TopUpStateInitiated>().having(
          (state) => state.url,
          'url',
          'https://test.com/payment',
        ),
      ],
      verify: (_) {
        verify(mockTopUpRepository.initiateTopUp({'amount': 100})).called(1);
        verify(mockRouter.go('/dashboard')).called(1);
      },
    );

    blocTest<TopUpCubit, TopUpState>(
      'initializeTopUp emits TopUpStateError when initiation fails',
      setUp: () {
        when(mockTopUpRepository.initiateTopUp({'amount': 100}))
            .thenThrow(Exception('Failed to initiate top-up'));
      },
      build: () => topUpCubit,
      act: (cubit) => cubit.initializeTopUp({'amount': 100}, mockRouter),
      expect: () => [
        isA<TopUpStateError>().having(
          (state) => state.errorMessage,
          'errorMessage',
          'Exception: Failed to initiate top-up',
        ),
      ],
    );

    test('create static method initializes cubit correctly', () async {
      when(mockTopUpRepository.getProviders())
          .thenAnswer((_) async => testTopUp);

      final cubit = await TopUpCubit.create(mockTopUpRepository);
      expect(cubit.state, isA<TopUpStateLoaded>());
      expect(
          (cubit.state as TopUpStateLoaded).providers, equals(testProviders));

      await cubit.close();
    });

    test('create static method handles initialization error', () async {
      when(mockTopUpRepository.getProviders())
          .thenThrow(Exception('Failed to load providers'));

      final cubit = await TopUpCubit.create(mockTopUpRepository);
      expect(cubit.state, isA<TopUpStateError>());

      await cubit.close();
    });

    blocTest<TopUpCubit, TopUpState>(
      'initializeTopUp navigates to dashboard after success',
      setUp: () {
        when(mockTopUpRepository.initiateTopUp({'amount': 100}))
            .thenAnswer((_) async => testTopUpInitiate);
      },
      build: () => topUpCubit,
      act: (cubit) => cubit.initializeTopUp({'amount': 100}, mockRouter),
      verify: (_) {
        verify(mockRouter.go('/dashboard')).called(1);
      },
    );

    blocTest<TopUpCubit, TopUpState>(
      'initializeTopUp handles various data formats',
      setUp: () {
        when(mockTopUpRepository
                .initiateTopUp({'amount': 100, 'currency': 'USD'}))
            .thenAnswer((_) async => testTopUpInitiate);
        when(mockTopUpRepository
                .initiateTopUp({'amount': 50.5, 'provider': 'test'}))
            .thenAnswer((_) async => testTopUpInitiate);
      },
      build: () => topUpCubit,
      act: (cubit) async {
        await cubit
            .initializeTopUp({'amount': 100, 'currency': 'USD'}, mockRouter);
        await cubit
            .initializeTopUp({'amount': 50.5, 'provider': 'test'}, mockRouter);
      },
      verify: (_) {
        verify(mockTopUpRepository
            .initiateTopUp({'amount': 100, 'currency': 'USD'})).called(1);
        verify(mockTopUpRepository
            .initiateTopUp({'amount': 50.5, 'provider': 'test'})).called(1);
      },
    );
  });
}
