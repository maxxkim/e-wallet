import 'package:zippy/data/api/api_withdrawal_initiate.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';

class WithdrawalInitiateMapper {
  static WithdrawalInitiate fromApi(ApiWithdrawalInitiate withdrawalInitiate) {
    return WithdrawalInitiate(
      status: withdrawalInitiate.status,
      transactionId: withdrawalInitiate.transactionId,
      paymentUrl: withdrawalInitiate.paymentUrl,
      description: withdrawalInitiate.description,
    );
  }
}
