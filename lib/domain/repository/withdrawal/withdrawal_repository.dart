import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';

abstract class WithdrawalRepository {
  Future<Withdrawal> getProviders();
  Future<WithdrawalInitiate> initiateWithdrawal(Map<String, dynamic> data);
}
