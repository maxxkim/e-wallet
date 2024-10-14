import 'package:zippy/data/api/api_balance.dart';

class BalanceMapper {
  static double fromApi(ApiBalance apiBalance) {
    return apiBalance.balance;
  }
}