import 'package:zippy/data/api/api_balance.dart';

class BalanceMapper {
  static int fromApi(ApiBalance apiBalance) {
    return apiBalance.balance;
  }
}
