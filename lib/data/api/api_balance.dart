import 'dart:math';

class ApiBalance {
  final num balance;
  final int decimal;

  ApiBalance.fromApi(Map<String, dynamic> map)
      : balance = map['wallet']['balance'],
        decimal = map['wallet']['decimal'] ?? 0;

  num getAdjustedBalance() {
    if (decimal == 0) return balance;
    return balance / (pow(10, decimal));
  }
}
