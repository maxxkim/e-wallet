import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardState(
    filterType: FilterType.period, 
    balance: getRandomBalance(),
    transactions: getRandomTransactions(),
    filteredTransactions: getRandomTransactions(),
  ));

  void selectFilter(FilterType filterType) {
    List<Transaction>? filteredTransactions = filterTransactions(filterType, state.transactions);

    emit(DashboardState(
      filterType: filterType,
      balance: state.balance,
      transactions: state.transactions, // keep the original transactions
      filteredTransactions: filteredTransactions, // updated transactions to display
    ));
  }

  List<Transaction>? filterTransactions(FilterType filterType, List<Transaction>? transactions) {
    if (transactions == null) return null;

    if (filterType == FilterType.deposit) {
      return transactions.where((transaction) => transaction.type == 'in').toList();
    } else if (filterType == FilterType.withdrawal) {
      return transactions.where((transaction) => transaction.type == 'out').toList();
    } 
    return transactions;
  }
  static double getRandomBalance(){
    final Random random = Random();
    return (random.nextDouble() * 1000000).roundToDouble(); // Случайная сумма
  }

  static List<Transaction> getRandomTransactions() {
    final Random random = Random();
    int numberOfTransactions = 20 + random.nextInt(31); // Generates a number between 20 and 50

    List<Transaction> transactions = [];

    for (int i = 0; i < numberOfTransactions; i++) {
      transactions.add(Transaction.generateRandomTransaction());
    }
    return transactions;
  }
}