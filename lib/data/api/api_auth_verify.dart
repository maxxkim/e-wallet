class ApiAuthVerify {
  final bool isVerified;
  final String accessToken;
  final String refreshToken;

  ApiAuthVerify.fromApi(Map<String, dynamic> map)
      : isVerified = map['results']['isVerified'],
        accessToken = map['results']['accessToken'],
        refreshToken = map['results']['refreshToken'];
}
