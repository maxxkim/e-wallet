import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';

class WithdrawalDataRepository extends WithdrawalRepository {
  final ApiUtil _apiUtil;

  WithdrawalDataRepository(this._apiUtil);

  @override
  Future<Withdrawal> getProviders() {
    return _apiUtil.getWithdrawalProviders();
  }

  @override
  Future<WithdrawalInitiate> initiateWithdrawal(Map<String, dynamic> data) {
    return _apiUtil.initiateWithdrawal(data);
  }
}
