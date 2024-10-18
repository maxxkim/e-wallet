
import 'package:zippy/data/api/api_top_up.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';

class TopUpMapper {
  static TopUp fromApi(ApiTopUp topUp) {
    return TopUp(
      status: topUp.status,
      url: topUp.url,
    );
  }
}