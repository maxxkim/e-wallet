class ApiAuthVerifyToken {
  final bool isVerified;

  ApiAuthVerifyToken.fromApi(Map<String, dynamic> map)
      : isVerified = map['isVerified'];
}
