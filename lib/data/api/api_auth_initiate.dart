class ApiAuthInitiate {
  final bool isNewUser;
  final String userId;
  final String? walletId;

  ApiAuthInitiate.fromApi(Map<String, dynamic> map)
      : isNewUser = map['isNewUser'],
        userId = map['userId'],
        walletId = map['wallet_id'];
}
