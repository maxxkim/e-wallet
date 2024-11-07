class ApiVerifyToken {
  final bool valid;

  ApiVerifyToken.fromApi(Map<String, dynamic> map) : valid = map['valid'];
}
