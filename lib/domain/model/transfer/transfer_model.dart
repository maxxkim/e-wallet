class TransferInitiate {
  final String transferHash;
  final String status;
  final Map<String, dynamic> wallet;

  TransferInitiate({
    required this.transferHash,
    required this.status,
    required this.wallet,
  });
}
