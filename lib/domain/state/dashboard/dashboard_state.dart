import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

class DashboardState {
  final FilterType filterType;
  final double balance;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions; 
  final String chosenMonth;

  const DashboardState({
    required this.filterType,
    required this.balance,
    this.transactions,
    this.filteredTransactions,
    required this.chosenMonth,
  });
}
