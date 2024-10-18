import 'package:zippy/data/api/api_transaction.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';

class TransactionMapper {
  static List<Transaction> fromApi(ApiTransaction apiTransaction) {
    return apiTransaction.transactions;
  }
}