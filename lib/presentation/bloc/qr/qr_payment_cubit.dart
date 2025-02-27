import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';
import 'package:zippy/presentation/events/transaction_events.dart';

class QrPaymentCubit extends Cubit<QrPaymentState> {
  final QrPaymentRepository _repository;
  QrPaymentCubit(this._repository) : super(QrPaymentInitial());

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['status'] == 'error' &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout occurred UwU~';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded >w<';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded nyaa~';
        case DioExceptionType.badResponse:
          return 'Server-chan says error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled uwu';
        default:
          return 'An unknown error occurred (ᵕ—ᴗ—)';
      }
    }
    return error.toString();
  }

  void startScanning() {
    emit(QrPaymentScanning());
  }

  Future<void> processQrCode(String code) async {
    try {
      emit(QrPaymentLoading());
      final response = await _repository.checkQrCode(code);
      emit(QrPaymentScanSuccess(qrPaymentResponse: response));
    } catch (e) {
      emit(QrPaymentScanError(_handleError(e)));
    }
  }

  Future<void> processPayment(QrPaymentResponse response, String amount) async {
    if (state is QrPaymentScanSuccess) {
      final currentState = state as QrPaymentScanSuccess;
      if (currentState.isProcessing) return;
      try {
        emit(currentState.copyWith(isProcessing: true, amountError: null));

        // Calculate payment amount based on QR code type
        double paymentAmount = response.qrCode.type == 'FIXED'
            ? response.qrCode.amount
            : double.parse(amount);

        Map<String, dynamic> additionalData = {};

        if (response.offer != null && response.activation != null) {
          final discountValue = double.tryParse(response.offer!.discount) ?? 0;
          final bonusValue = double.tryParse(response.offer!.bonus) ?? 0;

          additionalData['activation_id'] = response.activation!.id.toString();
          if (discountValue > 0) {
            additionalData['discount'] = discountValue;
          } else if (bonusValue > 0) {
            additionalData['bonus'] = bonusValue;
          }

          additionalData['merchant_name'] = response.offer!.merchantName;
        }

        final paymentResponse = await _repository.processPayment(
          response.qrCode.hash,
          paymentAmount,
          additionalData: additionalData,
        );

        // Create a transaction object for the payment info screen
        final transaction = Transaction(
          id: response.qrCode.hash,
          title: "Payment to ${response.merchant.name}",
          date: DateTime.now(),
          status: "completed",
          currency: response.qrCode.currency,
          type: "payout",
          amount: paymentAmount,
        );

        emit(QrPaymentSuccess(
          paymentResponse: paymentResponse,
          transaction: transaction,
        ));

        TransactionEventBus().fire(TransactionEvent(
          type: TransactionEventType.created,
          transaction: transaction,
        ));
      } catch (e) {
        emit(QrPaymentProcessError(_handleError(e)));
        emit(currentState.copyWith(isProcessing: false));
      }
    }
  }

  void resetScanner() {
    emit(QrPaymentScanning());
  }
}
