class GetWithdrawBody {
  final String merchantId;
  final String transactionId;
  final String country;
  final String currency;
  final String payMethod;
  final String documentId;
  final String amount; 
  final String email;
  final String name;
  final String timestamp;
  final String? payinExpirationTime;
  final String urlOk;
  final String urlError;
  final String objData; 

  GetWithdrawBody({
    required this.merchantId,
    required this.transactionId,
    required this.country,
    required this.currency,
    required this.payMethod,
    required this.documentId,
    required this.amount,
    required this.email,
    required this.name,
    required this.timestamp,
    this.payinExpirationTime,
    required this.urlOk,
    required this.urlError,
    required this.objData,
  });

  Map<String, dynamic> toApi() {
    return {
      'merchantId': merchantId,
      'transactionId': transactionId,
      'country': country,
      'currency': currency,
      'payMethod': payMethod,
      'documentId': documentId,
      'amount': amount,
      'email': email,
      'name': name,
      'timestamp': timestamp,
      'payinExpirationTime': payinExpirationTime,
      'url_OK': urlOk,
      'url_ERROR': urlError,
      'objData': objData,
    };
  }
}