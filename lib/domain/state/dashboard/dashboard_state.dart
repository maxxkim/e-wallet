// lib/domain/state/dashboard/dashboard_state.dart

import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

abstract class DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final FilterType filterType;
  final int selectedMonthNumber;
  final num balance;
  final String? accessToken;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions;
  final String searchQuery;

  DashboardStateLoaded({
    required this.filterType,
    required this.selectedMonthNumber,
    required this.balance,
    required this.transactions,
    required this.filteredTransactions,
    this.accessToken,
    this.searchQuery = '',
  });

  DashboardStateLoaded copyWith({
    FilterType? filterType,
    int? selectedMonthNumber,
    num? balance,
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? accessToken,
    String? searchQuery,
  }) {
    return DashboardStateLoaded(
      filterType: filterType ?? this.filterType,
      selectedMonthNumber: selectedMonthNumber ?? this.selectedMonthNumber,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      accessToken: accessToken ?? this.accessToken,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DashboardStateError extends DashboardState {
  final String errorMessage;

  DashboardStateError({
    required this.errorMessage,
  });
}

class DashboardStateLoggedOut extends DashboardState {}
