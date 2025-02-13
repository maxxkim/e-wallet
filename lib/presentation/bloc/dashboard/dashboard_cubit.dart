import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
          selectedTab: NavigationTab.home,
        ));

  void selectTab(int index) {
    if (state is DashboardStateLoaded) {
      final currentState = state as DashboardStateLoaded;
      emit(currentState.copyWith(
        selectedTab: NavigationTab.values[index],
      ));
    }
  }

  Future<void> loadData() async {
    try {
      if (state is DashboardStateLoggedOut) return;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String accessToken = prefs.getString('accessToken') ?? '';

      if (accessToken.isEmpty) {
        emit(DashboardStateLoggedOut());
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
          filteredTransactions: filteredTransactions ?? [],
          accessToken: accessToken,
          searchQuery: currentState.searchQuery,
          selectedTab: currentState.selectedTab,
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
        filteredTransactions: filteredTransactions ?? [],
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

    List<Transaction> filtered = [...transactions];

    // Get month number from month name
    final monthNumber = DateFormat('MMMM').parse(month).month;

    if (filterType == FilterType.deposit) {
      filtered = filtered.where((t) => t.type == 'payin').toList();
    } else if (filterType == FilterType.withdrawal) {
      filtered = filtered.where((t) => t.type == 'payout').toList();
    } else if (filterType == FilterType.period) {
      // Compare month numbers instead of strings
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

  void reset() {
    emit(DashboardStateLoaded(
      filterType: FilterType.period,
      chosenMonth: DateFormat('MMMM').format(DateTime.now()),
      balance: 0,
      transactions: [],
      filteredTransactions: [],
      selectedTab: NavigationTab.home,
    ));
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
        filteredTransactions: filteredTransactions ?? [],
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
        filteredTransactions: filteredTransactions ?? [],
      ));
    }
  }

  Future<void> logout(GoRouter router) async {
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
      if (error.response?.data != null &&
          error.response?.data['status'] == 'error' &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection error UwU. Please try again!';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded >w<';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded nyaa~';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled ~(=^･ω･^)';
        default:
          return 'An unknown error occurred ><';
      }
    }
    return error.toString();
  }
}
