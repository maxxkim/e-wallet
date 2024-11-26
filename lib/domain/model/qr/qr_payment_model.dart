class QrMerchant {
  final String name;
  final String url;

  QrMerchant({
    required this.name,
    required this.url,
  });

  factory QrMerchant.fromJson(Map<String, dynamic> json) {
    return QrMerchant(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class QrCode {
  final String hash;
  final String currency;
  final double amount;
  final String type;
  final String status;

  QrCode({
    required this.hash,
    required this.currency,
    required this.amount,
    required this.type,
    required this.status,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      hash: json['hash'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      status: json['status'] as String,
    );
  }
}

class QrPaymentResponse {
  final String status;
  final QrCode qrCode;
  final QrMerchant merchant;

  QrPaymentResponse({
    required this.status,
    required this.qrCode,
    required this.merchant,
  });

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrPaymentResponse(
      status: json['status'] as String,
      qrCode: QrCode.fromJson(json['qr_code'] as Map<String, dynamic>),
      merchant: QrMerchant.fromJson(json['merchant'] as Map<String, dynamic>),
    );
  }
}
