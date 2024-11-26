import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';

class QrPaymentDataRepository extends QrPaymentRepository {
  final ApiUtil _apiUtil;

  QrPaymentDataRepository(this._apiUtil);

  @override
  Future<QrPaymentResponse> checkQrCode(String hash) async {
    return _apiUtil.checkQrCode(hash);
  }

  @override
  Future<void> processPayment(String hash, double amount) async {
    return _apiUtil.processPayment(hash, amount);
  }
}
