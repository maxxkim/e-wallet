import 'package:zippy/domain/model/qr/payment_response_model.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';

abstract class QrPaymentState {}

class QrPaymentInitial extends QrPaymentState {}

class QrPaymentLoading extends QrPaymentState {}

class QrPaymentScanning extends QrPaymentState {}

class QrPaymentScanError extends QrPaymentState {
  final String message;

  QrPaymentScanError(this.message);
}

class QrPaymentScanSuccess extends QrPaymentState {
  final QrPaymentResponse qrPaymentResponse;
  final String? amountError;
  final bool isProcessing;

  QrPaymentScanSuccess({
    required this.qrPaymentResponse,
    this.amountError,
    this.isProcessing = false,
  });

  QrPaymentScanSuccess copyWith({
    QrPaymentResponse? qrPaymentResponse,
    String? amountError,
    bool? isProcessing,
  }) {
    return QrPaymentScanSuccess(
      qrPaymentResponse: qrPaymentResponse ?? this.qrPaymentResponse,
      amountError: amountError,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

class QrPaymentProcessError extends QrPaymentState {
  final String message;

  QrPaymentProcessError(this.message);
}

class QrPaymentSuccess extends QrPaymentState {
  final PaymentResponse paymentResponse;

  QrPaymentSuccess({required this.paymentResponse});
}
