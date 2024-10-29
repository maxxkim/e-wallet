import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/data/api/request/get_top_up_body.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';

class TopUpDataRepository extends TopUpRepository {
  final ApiUtil _apiUtil;

  TopUpDataRepository(this._apiUtil);

  @override
  Future<TopUp> getTopUp({
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
    final getTopUpBody = GetTopUpBody(
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

    return _apiUtil.getTopUp(requestBody: getTopUpBody);
  }
}
