import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/model/qr/payment_response_model.dart';

abstract class QrPaymentRepository {
  Future<QrPaymentResponse> checkQrCode(String hash);

  Future<PaymentResponse> processPayment(String hash, double amount,
      {Map<String, dynamic>? additionalData});
}
