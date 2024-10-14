import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

abstract class DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final FilterType filterType;
  final String chosenMonth;
  final double balance;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions;

  DashboardStateLoaded({
    required this.filterType,
    required this.chosenMonth,
    required this.balance,
    required this.transactions,
    required this.filteredTransactions,
  });

  // Implementing the copyWith method
  DashboardStateLoaded copyWith({
    FilterType? filterType, 
    String? chosenMonth,
    double? balance,
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
  }) {
    return DashboardStateLoaded(
      filterType: filterType ?? this.filterType,
      chosenMonth: chosenMonth ?? this.chosenMonth,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
    );
  }
}

class DashboardStateError extends DashboardState {
  final String errorMessage;

  DashboardStateError({
    required this.errorMessage,
  });
}