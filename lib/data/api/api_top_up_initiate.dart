class ApiTopUpInitiate {
  final String status;
  final String transactionId;
  final String paymentUrl;
  final String description;

  ApiTopUpInitiate.fromApi(Map<String, dynamic> map)
      : status = map['status'],
        transactionId = map['transactionId'],
        paymentUrl = map['paymentUrl'],
        description = map['description'];
}
