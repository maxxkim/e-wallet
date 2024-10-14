import 'package:zippy/domain/model/transaction/transaction_model.dart';

abstract class DashboardRepository {
  Future<double> getBalance();
  Future<List<Transaction>> getTransactions();
}