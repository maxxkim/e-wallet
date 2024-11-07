class ApiTopUp {
  final List<dynamic> providerList;

  ApiTopUp.fromApi(Map<String, dynamic> map) : providerList = map['providers'];
}
