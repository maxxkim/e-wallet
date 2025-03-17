import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';
import 'package:zippy/presentation/events/transaction_events.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;
  final SecureStorageService _secureStorage = SecureStorageService();
  late StreamSubscription<TransactionEvent> _eventSubscription;
  bool _isRefreshing = false;

  DashboardCubit(this._dashboardRepository)
      : super(DashboardStateLoaded(
          filterType: FilterType.period,
          chosenMonth: DateFormat('MMMM').format(DateTime.now()),
          balance: 0,
          transactions: [],
          filteredTransactions: [],
          selectedTab: NavigationTab.home,
        )) {
    // Listen to transaction events to refresh data when needed
    _eventSubscription =
        TransactionEventBus().events.listen(_handleTransactionEvent);
  }

  void _handleTransactionEvent(TransactionEvent event) {
    switch (event.type) {
      case TransactionEventType.created:
      case TransactionEventType.updated:
      case TransactionEventType.deleted:
      case TransactionEventType.balanceChanged:
        loadData();
        break;
    }
  }

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }

  void selectTab(int index) {
    if (state is DashboardStateLoaded) {
      final currentState = state as DashboardStateLoaded;
      emit(currentState.copyWith(
        selectedTab: NavigationTab.values[index],
      ));
    }
  }

  Future<void> loadData() async {
    // Prevent multiple simultaneous refreshes
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      if (state is DashboardStateLoggedOut) return;

      // Use SecureStorage instead of SharedPreferences
      final String? accessToken = await _secureStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        emit(DashboardStateLoggedOut());
        _isRefreshing = false;
        return;
      }

      // Store previous state if available
      DashboardStateLoaded? previousState;
      if (state is DashboardStateLoaded) {
        previousState = state as DashboardStateLoaded;
      }

      // Fetch new data
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
      } else if (previousState != null) {
        // Restore previous filters if state was lost
        final filteredTransactions = _applyFilters(
          transactions,
          previousState.filterType,
          previousState.chosenMonth,
          previousState.searchQuery,
        );
        emit(DashboardStateLoaded(
          filterType: previousState.filterType,
          chosenMonth: previousState.chosenMonth,
          balance: balance,
          transactions: transactions,
          filteredTransactions: filteredTransactions ?? [],
          accessToken: accessToken,
          searchQuery: previousState.searchQuery,
          selectedTab: previousState.selectedTab,
        ));
      } else {
        // Default state for first load
        final filteredTransactions = _applyFilters(
          transactions,
          FilterType.period,
          DateFormat('MMMM').format(DateTime.now()),
          '',
        );
        emit(DashboardStateLoaded(
          filterType: FilterType.period,
          chosenMonth: DateFormat('MMMM').format(DateTime.now()),
          balance: balance,
          transactions: transactions,
          filteredTransactions: filteredTransactions ?? [],
          accessToken: accessToken,
          searchQuery: '',
          selectedTab: NavigationTab.home,
        ));
      }
    } catch (e) {
      emit(DashboardStateError(
        errorMessage: _handleError(e),
      ));
    } finally {
      _isRefreshing = false;
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

    // Apply month filter
    final monthNumber = DateFormat('MMMM').parse(month).month;

    if (filterType == FilterType.deposit) {
      filtered = filtered.where((t) => t.type == 'payin').toList();
    } else if (filterType == FilterType.withdrawal) {
      filtered = filtered.where((t) => t.type == 'payout').toList();
    } else if (filterType == FilterType.period) {
      filtered = filtered.where((t) => t.date.month == monthNumber).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final lowercaseQuery = searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        return t.title.toLowerCase().contains(lowercaseQuery) ||
            t.id.toLowerCase().contains(lowercaseQuery) ||
            t.amount.toString().contains(lowercaseQuery);
      }).toList();
    }

    // Sort by date (newest first)
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
      // Use SecureStorage instead of SharedPreferences
      await _secureStorage.clearAllTokens();
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
