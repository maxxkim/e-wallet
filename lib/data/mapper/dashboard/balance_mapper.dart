import 'package:zippy/data/api/api_balance.dart';

class BalanceMapper {
  static num fromApi(ApiBalance apiBalance) {
    return apiBalance.getAdjustedBalance();
  }
}
