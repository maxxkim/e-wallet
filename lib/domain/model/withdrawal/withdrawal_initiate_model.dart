class WithdrawalInitiate {
  final String status;
  final String transactionId;
  final String paymentUrl;
  final String description;

  WithdrawalInitiate({
    required this.status,
    required this.transactionId,
    required this.paymentUrl,
    required this.description,
  });
}
