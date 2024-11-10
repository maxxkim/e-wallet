import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit(this._dashboardRepository)
      : super(DashboardStateLoaded(
          filterType: FilterType.period,
          chosenMonth: DateFormat('MMMM').format(DateTime.now()),
          balance: 0,
          transactions: [],
          filteredTransactions: [],
        ));

  static Future<DashboardCubit> create(
      DashboardRepository dashboardRepository) async {
    final cubit = DashboardCubit(dashboardRepository);
    await cubit.loadData();
    return cubit;
  }

  Future<void> loadData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        emit(DashboardStateError(errorMessage: 'Sign in token is missing'));
        return;
      }

      final balance = await _dashboardRepository.getBalance();
      final transactions = await _dashboardRepository.getTransactions();

      if (state is DashboardStateLoaded) {
        final currentState = state as DashboardStateLoaded;
        final filteredTransactions = _applyFilters(
          transactions,
          currentState.filterType,
          currentState.chosenMonth,
          currentState.searchQuery,
        );

        emit(DashboardStateLoaded(
          filterType: currentState.filterType,
          chosenMonth: currentState.chosenMonth,
          balance: balance,
          transactions: transactions,
          filteredTransactions: filteredTransactions,
          accessToken: accessToken,
          searchQuery: currentState.searchQuery,
        ));
      }
    } catch (e) {
      emit(DashboardStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  void searchTransactions(String query) {
    if (state is DashboardStateLoaded) {
      final currentState = state as DashboardStateLoaded;
      final filteredTransactions = _applyFilters(
        currentState.transactions,
        currentState.filterType,
        currentState.chosenMonth,
        query,
      );

      emit(currentState.copyWith(
        filteredTransactions: filteredTransactions,
        searchQuery: query,
      ));
    }
  }

  List<Transaction>? _applyFilters(
    List<Transaction>? transactions,
    FilterType filterType,
    String month,
    String searchQuery,
  ) {
    if (transactions == null) return null;

    var filtered = transactions.where((transaction) {
      bool matchesFilter = true;
      bool matchesSearch = true;

      // Apply type filter
      if (filterType == FilterType.deposit) {
        matchesFilter = transaction.type == 'payin';
      } else if (filterType == FilterType.withdrawal) {
        matchesFilter = transaction.type == 'payout';
      } else if (filterType == FilterType.period) {
        matchesFilter = DateFormat('MMMM').format(transaction.date) == month;
      }

      // Apply search filter if query is not empty
      if (searchQuery.isNotEmpty) {
        final lowercaseQuery = searchQuery.toLowerCase();
        matchesSearch =
            transaction.title.toLowerCase().contains(lowercaseQuery) ||
                transaction.id.toLowerCase().contains(lowercaseQuery) ||
                transaction.amount.toString().contains(lowercaseQuery);
      }

      return matchesFilter && matchesSearch;
    }).toList();

    // Sort by date
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      emit(DashboardStateLoggedOut());
    } catch (e) {
      emit(DashboardStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  void selectFilter(FilterType filterType) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      final filteredTransactions = _applyFilters(
        currentState.transactions,
        filterType,
        currentState.chosenMonth,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        filterType: filterType,
        filteredTransactions: filteredTransactions,
      ));
    }
  }

  void selectMonth(String month) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      final filteredTransactions = _applyFilters(
        currentState.transactions,
        currentState.filterType,
        month,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        chosenMonth: month,
        filteredTransactions: filteredTransactions,
      ));
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection error. Please try again.';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded.';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded.';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'An unknown error occurred.';
      }
    }
    return error.toString();
  }
}
