class AuthVerify {
  final bool isVerified;
  final String accessToken;
  final String refreshToken;

  AuthVerify({
    required this.isVerified,
    required this.accessToken,
    required this.refreshToken,
  });
}