class AuthInitiate {
  final bool isNewUser;
  final String userId;
  final String walletId;

  AuthInitiate({
    required this.isNewUser,
    required this.userId,
    required this.walletId,
  });
}