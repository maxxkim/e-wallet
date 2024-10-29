import 'package:zippy/domain/model/transaction/transaction_model.dart';

class ApiTransaction {
  final List<Transaction> transactions;

  ApiTransaction.fromApi(Map<String, dynamic> map)
      : transactions = (map['transactions'] as List<dynamic>)
            .map((transactionMap) => Transaction(
                  id: transactionMap['transactionId'],
                  title:
                      transactionMap['name'], // или другое поле для заголовка
                  date: DateTime.parse(transactionMap['createdAt']),
                  status: transactionMap['status']
                      .toLowerCase(), // Приводим к нижнему регистру
                  currency: transactionMap['currency'],
                  type: transactionMap['type']
                      .toLowerCase(), // Приводим к нижнему регистру
                  amount: double.parse(transactionMap['amount']),
                ))
            .toList();
}
