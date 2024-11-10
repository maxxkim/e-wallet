import 'package:zippy/data/api/api_top_up_initiate.dart';
import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';

class TopUpInitiateMapper {
  static TopUpInitiate fromApi(ApiTopUpInitiate topUpInitiate) {
    return TopUpInitiate(
      status: topUpInitiate.status,
      transactionId: topUpInitiate.transactionId,
      paymentUrl: topUpInitiate.paymentUrl,
      description: topUpInitiate.description,
    );
  }
}
