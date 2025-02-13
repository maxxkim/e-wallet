import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

import 'dashboard_cubit_test.mocks.dart';

@GenerateMocks([DashboardRepository, GoRouter])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DashboardCubit dashboardCubit;
  late DashboardRepository mockDashboardRepository;
  late GoRouter mockRouter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockDashboardRepository = MockDashboardRepository();
    mockRouter = MockGoRouter();
    dashboardCubit = DashboardCubit(mockDashboardRepository);
  });

  tearDown(() {
    dashboardCubit.close();
  });

  group('DashboardCubit Tests', () {
    final testTransactions = [
      Transaction(
        id: "1",
        title: "Test Deposit",
        date: DateTime(2025, 1, 1),
        status: "completed",
        currency: "USD",
        type: "payin",
        amount: 100.0,
      ),
      Transaction(
        id: "2",
        title: "Test Withdrawal",
        date: DateTime(2025, 1, 2),
        status: "completed",
        currency: "USD",
        type: "payout",
        amount: 50.0,
      ),
    ];

    const testBalance = 1000.0;

    blocTest<DashboardCubit, DashboardState>(
      'initial state is loaded with empty data',
      build: () => dashboardCubit,
      verify: (cubit) {
        expect(cubit.state, isA<DashboardStateLoaded>());
        final state = cubit.state as DashboardStateLoaded;
        expect(state.balance, equals(0));
        expect(state.transactions, isEmpty);
        expect(state.filteredTransactions, isEmpty);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'loadData emits state with transactions and balance when successful',
      setUp: () {
        when(mockDashboardRepository.getBalance())
            .thenAnswer((_) async => testBalance);
        when(mockDashboardRepository.getTransactions())
            .thenAnswer((_) async => testTransactions);
        SharedPreferences.setMockInitialValues({
          'accessToken': 'test_token',
        });
      },
      build: () => dashboardCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.balance, 'balance', testBalance)
            .having(
                (state) => state.transactions?.length, 'transactions length', 2)
            .having((state) => state.filteredTransactions?.length,
                'filtered transactions length', 2),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'loadData emits error state when repository throws',
      setUp: () {
        when(mockDashboardRepository.getBalance())
            .thenThrow(Exception('Failed to load balance'));
        SharedPreferences.setMockInitialValues({
          'accessToken': 'test_token',
        });
      },
      build: () => dashboardCubit,
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<DashboardStateError>().having(
          (state) => state.errorMessage,
          'errorMessage',
          contains('Failed to load balance'),
        ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'searchTransactions filters transactions correctly',
      setUp: () async {
        when(mockDashboardRepository.getBalance())
            .thenAnswer((_) async => testBalance);
        when(mockDashboardRepository.getTransactions())
            .thenAnswer((_) async => testTransactions);
        SharedPreferences.setMockInitialValues({
          'accessToken': 'test_token',
        });
      },
      build: () => dashboardCubit,
      act: (cubit) async {
        await cubit.loadData();
        cubit.searchTransactions("Deposit");
      },
      skip: 1, // Skip the loadData state
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.filteredTransactions?.length,
                'filtered transactions length', 1)
            .having((state) => state.filteredTransactions?.first.title,
                'filtered transaction title', 'Test Deposit'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'selectFilter filters transactions by type correctly',
      setUp: () async {
        when(mockDashboardRepository.getBalance())
            .thenAnswer((_) async => testBalance);
        when(mockDashboardRepository.getTransactions())
            .thenAnswer((_) async => testTransactions);
        SharedPreferences.setMockInitialValues({
          'accessToken': 'test_token',
        });
      },
      build: () => dashboardCubit,
      act: (cubit) async {
        await cubit.loadData();
        cubit.selectFilter(FilterType.deposit);
      },
      skip: 1, // Skip the loadData state
      expect: () => [
        isA<DashboardStateLoaded>()
            .having(
                (state) => state.filterType, 'filterType', FilterType.deposit)
            .having((state) => state.filteredTransactions?.length,
                'filtered transactions length', 1)
            .having((state) => state.filteredTransactions?.first.type,
                'transaction type', 'payin'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'selectMonth filters transactions by month correctly',
      setUp: () async {
        when(mockDashboardRepository.getBalance())
            .thenAnswer((_) async => testBalance);
        when(mockDashboardRepository.getTransactions())
            .thenAnswer((_) async => testTransactions);
        SharedPreferences.setMockInitialValues({
          'accessToken': 'test_token',
        });
      },
      build: () => dashboardCubit,
      act: (cubit) async {
        await cubit.loadData();
        cubit.selectMonth('January');
      },
      skip: 1, // Skip the loadData state
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.chosenMonth, 'chosenMonth', 'January')
            .having((state) => state.filteredTransactions?.length,
                'filtered transactions length', 2),
      ],
    );

    test('logout clears preferences and emits logged out state', () async {
      SharedPreferences.setMockInitialValues({
        'accessToken': 'test_token',
        'refreshToken': 'refresh_token',
      });

      await dashboardCubit.logout(mockRouter);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('accessToken'), isNull);
      expect(prefs.getString('refreshToken'), isNull);
      expect(dashboardCubit.state, isA<DashboardStateLoggedOut>());
    });

    test('reset returns cubit to initial state', () {
      dashboardCubit.reset();

      expect(dashboardCubit.state, isA<DashboardStateLoaded>());
      final state = dashboardCubit.state as DashboardStateLoaded;
      expect(state.balance, equals(0));
      expect(state.transactions, isEmpty);
      expect(state.filteredTransactions, isEmpty);
      expect(state.filterType, equals(FilterType.period));
    });
  });
}
