class ApiTopUp {
  final String status;
  final String url;

  ApiTopUp.fromApi(Map<String, dynamic> map)
      : status = map['results']['status'],
        url = map['results']['url'];
}