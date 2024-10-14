
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';

class DashboardDataRepository extends DashboardRepository {
  final ApiUtil _apiUtil;

  DashboardDataRepository(this._apiUtil);

  @override
  Future<double> getBalance() {
    return _apiUtil.getBalance();
  }
}