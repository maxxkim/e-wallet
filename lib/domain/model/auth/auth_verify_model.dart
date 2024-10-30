class AuthVerify {
  final bool isVerified;
  final String? accessToken;
  final String? refreshToken;

  AuthVerify({
    required this.isVerified,
    this.accessToken,
    this.refreshToken,
  });
}
