class ApiBalance {
  final double balance;

  ApiBalance.fromApi(Map<String, dynamic> map)
      : balance = map['wallet']['balance'];
}
