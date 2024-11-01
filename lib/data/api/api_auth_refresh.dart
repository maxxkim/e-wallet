class ApiAuthRefresh {
  final String? accessToken;
  final String? refreshToken;

  ApiAuthRefresh.fromApi(Map<String, dynamic> map)
      : accessToken = map['accessToken'],
        refreshToken = map['refreshToken'];
}
