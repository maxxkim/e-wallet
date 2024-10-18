
// ignore_for_file: non_constant_identifier_names

import 'package:zippy/data/api/api_withdraw.dart';
import 'package:zippy/domain/model/withdraw/withdraw_model.dart';

class WithdrawMapper {
  static Withdraw fromApi(ApiWithdraw WithdrawMapper) {
    return Withdraw(
      status: WithdrawMapper.status,
      url: WithdrawMapper.url,
    );
  }
}