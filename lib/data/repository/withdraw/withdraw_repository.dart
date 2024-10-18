
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/data/api/request/get_withdraw_body.dart';
import 'package:zippy/domain/model/withdraw/withdraw_model.dart';
import 'package:zippy/domain/repository/withdraw/withdraw_repository.dart';

class WithdrawDataRepository extends WithdrawRepository {
  final ApiUtil _apiUtil;

  WithdrawDataRepository(this._apiUtil);

  @override
  Future<Withdraw> getWithdraw({
    required String merchantId,
    required String transactionId,
    required String country,
    required String currency,
    required String payMethod,
    required String documentId,
    required String amount, 
    required String email,
    required String name,
    required String timestamp,
    String? payinExpirationTime, 
    required String urlOk,
    required String urlError,
    required String objData,
  }) {
    final getWithdrawBody = GetWithdrawBody(
      merchantId: merchantId,
      transactionId: transactionId,
      country: country,
      currency: currency,
      payMethod: payMethod,
      documentId: documentId,
      amount: amount,
      email: email,
      name: name,
      timestamp: timestamp,
      payinExpirationTime: payinExpirationTime,
      urlOk: urlOk,
      urlError: urlError,
      objData: objData,
    );

    return _apiUtil.getWithdraw(requestBody: getWithdrawBody);
  }
}