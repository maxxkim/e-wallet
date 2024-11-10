class ApiBalance {
  final num balance;

  ApiBalance.fromApi(Map<String, dynamic> map)
      : balance = map['wallet']['balance'];
}
