import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';

class WithdrawalMapper {
  static Withdrawal fromApi(ApiWithdraw withdrawal) {
    return Withdrawal(
      providerList: withdrawal.providerList,
    );
  }
}
