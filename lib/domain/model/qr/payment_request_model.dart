// lib/domain/model/qr/payment_request_model.dart

class PaymentRequest {
  final String qrCodeHash;
  final double amount;
  final double? discount;
  final double? bonus;

  PaymentRequest({
    required this.qrCodeHash,
    required this.amount,
    this.discount,
    this.bonus,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'qr_code_hash': qrCodeHash,
      'amount': amount,
    };

    if (discount != null) {
      data['discount'] = discount;
    }

    if (bonus != null) {
      data['bonus'] = bonus;
    }

    return data;
  }
}
