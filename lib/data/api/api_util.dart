import 'package:zippy/data/api/service/api_service.dart';
import 'package:zippy/data/mapper/auth/auth_initiate_mapper.dart';
import 'package:zippy/data/mapper/auth/auth_refresh_mapper.dart';
import 'package:zippy/data/mapper/auth/auth_verify_mapper.dart';
import 'package:zippy/data/mapper/auth/token_verification_mapper.dart';
import 'package:zippy/data/mapper/dashboard/balance_mapper.dart';
import 'package:zippy/data/mapper/dashboard/transaction_mapper.dart';
import 'package:zippy/data/mapper/topUp/top_up_initiate_mapper.dart';
import 'package:zippy/data/mapper/topUp/top_up_mapper.dart';
import 'package:zippy/data/mapper/withdrawal/withdrawal_initiate.dart';
import 'package:zippy/data/mapper/withdrawal/withdrawal_mapper.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';

class ApiUtil {
  final ApiService _apiService;

  ApiUtil(this._apiService);

  Future<List<Transaction>> getTransactions() async {
    final result = await _apiService.getTransactions();
    return TransactionMapper.fromApi(result);
  }

  Future<num> getBalance() async {
    final result = await _apiService.getBalance();
    return BalanceMapper.fromApi(result);
  }

  Future<AuthInitiate> initiateAuth(String phone) async {
    final result = await _apiService.initiateAuth(phone);
    return AuthInitiateMapper.fromApi(result);
  }

  Future<AuthVerify> verifyAuth(
    String code,
    String phone,
    String userId,
  ) async {
    final result = await _apiService.verifyAuth(code, phone, userId);
    return AuthVerifyMapper.fromApi(result);
  }

  Future<AuthRefresh> refreshAuth(String refreshToken) async {
    final result = await _apiService.refreshAuth(refreshToken);
    return AuthRefreshMapper.fromApi(result);
  }

  Future<bool> verifyToken(String accessToken) async {
    final result = await _apiService.verifyToken(accessToken);
    return TokenVerificationMapper.fromApi(result);
  }

  Future<TopUp> getProviders() async {
    final result = await _apiService.getProviders();
    return TopUpMapper.fromApi(result);
  }

  Future<TopUpInitiate> initiateTopUp(Map<String, dynamic> data) async {
    final result = await _apiService.initiateTopUp(data);
    return TopUpInitiateMapper.fromApi(result);
  }

  Future<Withdrawal> getWithdrawalProviders() async {
    final result = await _apiService.getWithdrawalProviders();
    return WithdrawalMapper.fromApi(result);
  }

  Future<WithdrawalInitiate> initiateWithdrawal(
      Map<String, dynamic> data) async {
    final result = await _apiService.initiateWithdrawal(data);
    return WithdrawalInitiateMapper.fromApi(result);
  }
}
