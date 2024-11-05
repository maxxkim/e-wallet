import 'package:zippy/domain/model/transaction/transaction_model.dart';

abstract class DashboardRepository {
  Future<int> getBalance();
  Future<List<Transaction>> getTransactions();
}
