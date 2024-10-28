class ApiAuthInitiate{
  final bool isNewUser;
  final String userId;
  final String walletId;

  ApiAuthInitiate.fromApi(Map<String, dynamic> map)
      : isNewUser = map['results']['isNewUser'],
        userId = map['results']['userId'],
        walletId = map['results']['wallet_id'];
}