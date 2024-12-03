import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit(this._dashboardRepository)
      : super(DashboardStateLoaded(
          filterType: FilterType.period,
          selectedMonthNumber: DateTime.now().month,
          balance: 0,
          transactions: [],
          filteredTransactions: [],
        ));

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
          currentState.selectedMonthNumber,
          currentState.searchQuery,
        );

        emit(DashboardStateLoaded(
          filterType: currentState.filterType,
          selectedMonthNumber: currentState.selectedMonthNumber,
          balance: balance,
          transactions: transactions,
          filteredTransactions: filteredTransactions ?? [],
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
        currentState.selectedMonthNumber,
        query,
      );

      emit(currentState.copyWith(
        filteredTransactions: filteredTransactions ?? [],
        searchQuery: query,
      ));
    }
  }

  List<Transaction>? _applyFilters(
    List<Transaction>? transactions,
    FilterType filterType,
    int monthNumber,
    String searchQuery,
  ) {
    if (transactions == null) return null;

    List<Transaction> filtered = [...transactions];

    if (filterType == FilterType.deposit) {
      filtered = filtered.where((t) => t.type == 'payin').toList();
    } else if (filterType == FilterType.withdrawal) {
      filtered = filtered.where((t) => t.type == 'payout').toList();
    } else if (filterType == FilterType.period) {
      filtered = filtered.where((t) => t.date.month == monthNumber).toList();
    }

    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(lowercaseQuery) ||
            t.id.toLowerCase().contains(lowercaseQuery) ||
            t.amount.toString().contains(lowercaseQuery);
      }).toList();
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void selectFilter(FilterType filterType) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      final filteredTransactions = _applyFilters(
        currentState.transactions,
        filterType,
        currentState.selectedMonthNumber,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        filterType: filterType,
        filteredTransactions: filteredTransactions ?? [],
      ));
    }
  }

  void selectMonth(int monthNumber) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      final filteredTransactions = _applyFilters(
        currentState.transactions,
        currentState.filterType,
        monthNumber,
        currentState.searchQuery,
      );

      emit(currentState.copyWith(
        selectedMonthNumber: monthNumber,
        filteredTransactions: filteredTransactions ?? [],
      ));
    }
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
