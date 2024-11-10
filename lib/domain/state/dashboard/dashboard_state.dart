import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

abstract class DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final FilterType filterType;
  final String chosenMonth;
  final num balance;
  final String? accessToken;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions;
  final String searchQuery;

  DashboardStateLoaded({
    required this.filterType,
    required this.chosenMonth,
    required this.balance,
    required this.transactions,
    required this.filteredTransactions,
    this.accessToken,
    this.searchQuery = '',
  });

  DashboardStateLoaded copyWith({
    FilterType? filterType,
    String? chosenMonth,
    num? balance,
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? accessToken,
    String? searchQuery,
  }) {
    return DashboardStateLoaded(
      filterType: filterType ?? this.filterType,
      chosenMonth: chosenMonth ?? this.chosenMonth,
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
