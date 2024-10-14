import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

class DashboardState {
  final FilterType filterType;
  final String chosenMonth;
  final double balance;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions;

  DashboardState({
    required this.filterType,
    required this.chosenMonth,
    required this.balance,
    required this.transactions,
    required this.filteredTransactions,
  });

  factory DashboardState.initial() {
    return DashboardState(
      filterType: FilterType.period,
      chosenMonth: DateFormat('MMMM').format(DateTime.now()),
      balance: 0.0, 
      transactions: [],
      filteredTransactions: [],
    );
  }
}