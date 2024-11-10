class TopUpInitiate {
  final String status;
  final String transactionId;
  final String paymentUrl;
  final String description;

  TopUpInitiate({
    required this.status,
    required this.transactionId,
    required this.paymentUrl,
    required this.description,
  });
}
