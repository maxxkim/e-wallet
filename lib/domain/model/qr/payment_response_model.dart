class PaymentResponse {
  final String status;
  final Payment payment;
  final Wallet wallet;

  PaymentResponse({
    required this.status,
    required this.payment,
    required this.wallet,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      status: json['status'] as String,
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
      wallet: Wallet.fromJson(json['wallet'] as Map<String, dynamic>),
    );
  }
}

class Payment {
  final String hash;
  final String currency;
  final double amount;
  final String? returnUrl;
  final String status;

  Payment({
    required this.hash,
    required this.currency,
    required this.amount,
    this.returnUrl,
    required this.status,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      hash: json['hash'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      returnUrl: json['return_url'] as String?,
      status: json['status'] as String,
    );
  }
}

class Wallet {
  final String hash;
  final String currency;
  final double balance;
  final double reserve;

  Wallet({
    required this.hash,
    required this.currency,
    required this.balance,
    required this.reserve,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      hash: json['hash'] as String,
      currency: json['currency'] as String,
      balance: (json['balance'] as num).toDouble(),
      reserve: (json['reserve'] as num).toDouble(),
    );
  }
}
