import 'package:zippy/data/api/request/get_top_up_body.dart';
import 'package:zippy/data/api/request/get_withdraw_body.dart';
import 'package:zippy/data/api/service/api_service.dart';
import 'package:zippy/data/mapper/dashboard/balance_mapper.dart';
import 'package:zippy/data/mapper/dashboard/transaction_mapper.dart';
import 'package:zippy/data/mapper/top_up/top_up_mapper.dart';
import 'package:zippy/data/mapper/withdraw/withdraw_mapper.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/withdraw/withdraw_model.dart';

class ApiUtil {
  final ApiService _apiService;

  ApiUtil(this._apiService);

  Future<TopUp> getTopUp({
    required GetTopUpBody requestBody,
  }) async {
    final result = await _apiService.getTopUp(requestBody);
    return TopUpMapper.fromApi(result);
  }

  Future<Withdraw> getWithdraw({
    required GetWithdrawBody requestBody,
  }) async {
    final result = await _apiService.getWithdraw(requestBody);
    return WithdrawMapper.fromApi(result);
  }

  Future<double> getBalance() async {
    final result = await _apiService.getBalance();
    return BalanceMapper.fromApi(result);
  }

  Future<List<Transaction>> getTransactions() async {
    final result = await _apiService.getTransactions();
    return TransactionMapper.fromApi(result);
  }
}