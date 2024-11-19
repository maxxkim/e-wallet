class TransferInitiate {
  final String transferHash;
  final String currency;
  final int amount;
  final Map<String, dynamic> senderData;
  final Map<String, dynamic> recipientData;

  TransferInitiate({
    required this.transferHash,
    required this.currency,
    required this.amount,
    required this.senderData,
    required this.recipientData,
  });
}
