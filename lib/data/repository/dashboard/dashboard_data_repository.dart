import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';

class DashboardDataRepository extends DashboardRepository {
  final ApiUtil _apiUtil;

  DashboardDataRepository(this._apiUtil);

  @override
  Future<num> getBalance() {
    return _apiUtil.getBalance();
  }

  @override
  Future<List<Transaction>> getTransactions() {
    return _apiUtil.getTransactions();
  }
}
