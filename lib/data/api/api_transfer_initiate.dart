class ApiTransferInitiate {
  final String transferHash;
  final String currency;
  final int amount;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic> recipientData;

  ApiTransferInitiate.fromApi(Map<String, dynamic> map)
      : transferHash = map['transferHash'],
        currency = map['currency'],
        amount = map['amount'],
        senderData = map['senderData'],
        recipientData = map['recipientData'];
}
