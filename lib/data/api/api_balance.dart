class ApiBalance {
  final int balance;

  ApiBalance.fromApi(Map<String, dynamic> map)
      : balance = map['wallet']['balance'];
}
