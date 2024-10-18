class ApiWithdraw {
  final String status;
  final String url;

  ApiWithdraw.fromApi(Map<String, dynamic> map)
      : status = map['results']['status'],
        url = map['results']['url'];
}