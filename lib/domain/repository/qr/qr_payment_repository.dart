import 'package:zippy/domain/model/qr/qr_payment_model.dart';

abstract class QrPaymentRepository {
  Future<QrPaymentResponse> checkQrCode(String hash);
  Future<void> processPayment(String hash, double amount);
}
