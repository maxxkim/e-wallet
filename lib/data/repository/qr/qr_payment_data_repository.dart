import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/model/qr/payment_response_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';

class QrPaymentDataRepository extends QrPaymentRepository {
  final ApiUtil _apiUtil;

  QrPaymentDataRepository(this._apiUtil);

  @override
  Future<QrPaymentResponse> checkQrCode(String hash) async {
    return _apiUtil.checkQrCode(hash);
  }

  @override
  Future<PaymentResponse> processPayment(String hash, double amount,
      {Map<String, dynamic>? additionalData}) async {
    // Create base request data
    final Map<String, dynamic> requestData = {
      'qr_code_hash': hash,
      'amount': amount,
    };

    // Add additional data if provided
    if (additionalData != null && additionalData.isNotEmpty) {
      // Add activation_id if present
      if (additionalData.containsKey('activation_id')) {
        requestData['activation_id'] = additionalData['activation_id'];
      }

      // Add discount info if present
      if (additionalData.containsKey('discount')) {
        requestData['discount'] = additionalData['discount'];
      }

      // Add bonus info if present
      if (additionalData.containsKey('bonus')) {
        requestData['bonus'] = additionalData['bonus'];
      }
    }

    return _apiUtil.processPayment(requestData);
  }
}
