import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'dashboard_repository_mock.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDashboardRepository mockDashboardRepository;
  late DashboardCubit dashboardCubit;

  // Get current month for test data
  final currentDate = DateTime.now();
  final currentMonth = DateFormat('MMMM').format(currentDate);

  final testTransactions = [
    Transaction(
      id: "1",
      title: "Test Transaction 1",
      date: DateTime(currentDate.year, currentDate.month, 1), // Current month
      status: "completed",
      currency: "USD",
      type: "payin",
      amount: 100.0,
    ),
    Transaction(
      id: "2",
      title: "Test Transaction 2",
      date: DateTime(currentDate.year, currentDate.month, 2), // Current month
      status: "pending",
      currency: "USD",
      type: "payout",
      amount: 50.0,
    ),
  ];

  const testBalance = 1000.0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'accessToken': 'test-token'});
    mockDashboardRepository = MockDashboardRepository();

    // Setup default responses
    when(mockDashboardRepository.getBalance())
        .thenAnswer((_) async => testBalance);
    when(mockDashboardRepository.getTransactions())
        .thenAnswer((_) async => testTransactions);
  });

  tearDown(() {
    dashboardCubit.close();
  });

  group('DashboardCubit Tests', () {
    test('initial state is correct', () {
      dashboardCubit = DashboardCubit(mockDashboardRepository);
      expect(
        dashboardCubit.state,
        isA<DashboardStateLoaded>()
            .having(
                (state) => state.filterType, 'filterType', FilterType.period)
            .having((state) => state.balance, 'balance', 0)
            .having((state) => state.transactions, 'transactions', []).having(
                (state) => state.filteredTransactions,
                'filteredTransactions', []),
      );
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits loaded state with data when loadData is called successfully',
      build: () => DashboardCubit(mockDashboardRepository),
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.balance, 'balance', testBalance)
            .having(
                (state) => state.transactions, 'transactions', testTransactions)
            .having(
              (state) => state.filteredTransactions?.length,
              'filteredTransactions length',
              2, // Both transactions are in current month
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'filters transactions correctly when deposit filter is selected',
      build: () => DashboardCubit(mockDashboardRepository),
      act: (cubit) async {
        await cubit.loadData();
        cubit.selectFilter(FilterType.deposit);
      },
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.balance, 'balance', testBalance)
            .having(
                (state) => state.transactions, 'transactions', testTransactions)
            .having(
              (state) => state.filteredTransactions?.length,
              'filteredTransactions length',
              2, // Initial load shows both transactions
            ),
        isA<DashboardStateLoaded>()
            .having(
                (state) => state.filterType, 'filterType', FilterType.deposit)
            .having(
              (state) => state.filteredTransactions?.length,
              'filteredTransactions length',
              1, // Only payin transaction
            )
            .having(
              (state) => state.filteredTransactions?.first.type,
              'filtered transaction type',
              'payin',
            ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits error state when loadData fails',
      setUp: () {
        when(mockDashboardRepository.getBalance())
            .thenThrow(Exception('Failed to load balance'));
      },
      build: () => DashboardCubit(mockDashboardRepository),
      act: (cubit) => cubit.loadData(),
      expect: () => [
        isA<DashboardStateError>().having((state) => state.errorMessage,
            'errorMessage', 'Exception: Failed to load balance'),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'searches transactions correctly',
      build: () => DashboardCubit(mockDashboardRepository),
      act: (cubit) async {
        await cubit.loadData();
        cubit.searchTransactions('Test Transaction 1');
      },
      expect: () => [
        isA<DashboardStateLoaded>()
            .having((state) => state.balance, 'balance', testBalance)
            .having(
                (state) => state.transactions, 'transactions', testTransactions)
            .having(
              (state) => state.filteredTransactions?.length,
              'filteredTransactions length',
              2, // Initial load shows both transactions
            ),
        isA<DashboardStateLoaded>()
            .having(
              (state) => state.filteredTransactions?.length,
              'filteredTransactions length',
              1, // Only matching transaction
            )
            .having(
              (state) => state.filteredTransactions?.first.title,
              'filtered transaction title',
              'Test Transaction 1',
            ),
      ],
    );
  });
}
