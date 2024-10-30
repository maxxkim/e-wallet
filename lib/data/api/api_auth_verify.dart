class ApiAuthVerify {
  final bool isVerified;
  final String? accessToken;
  final String? refreshToken;

  ApiAuthVerify.fromApi(Map<String, dynamic> map)
      : isVerified = map['isVerified'],
        accessToken = map['accessToken'],
        refreshToken = map['refreshToken'];
}
