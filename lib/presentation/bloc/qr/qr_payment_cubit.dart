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

        // Use fixed amount if type is FIXED, otherwise use the entered amount
        double paymentAmount = response.qrCode.type == 'FIXED'
            ? response.qrCode.amount
            : double.parse(amount);

        // Prepare the request data
        Map<String, dynamic> requestData = {
          'qr_code_hash': response.qrCode.hash,
          'amount': paymentAmount,
        };

        // Add discount if available from QR code
        if (response.qrCode.discount != null && response.qrCode.discount! > 0) {
          requestData['discount'] = response.qrCode.discount;
        }

        // Add activation_id if offer and activation are available
        if (response.offer != null && response.activation != null) {
          requestData['activation_id'] = response.activation!.id.toString();

          // Add discount from offer if not already added from QR code
          if (response.qrCode.discount == null ||
              response.qrCode.discount == 0) {
            final discountValue =
                double.tryParse(response.offer!.discount) ?? 0;
            final bonusValue = double.tryParse(response.offer!.bonus) ?? 0;

            if (discountValue > 0) {
              if (response.offer!.discountType == 'PERCENTAGE') {
                double calculatedDiscount =
                    paymentAmount * (discountValue / 100);
                requestData['discount'] = calculatedDiscount;
              } else {
                requestData['discount'] = discountValue;
              }
            } else if (bonusValue > 0) {
              if (response.offer!.bonusType == 'PERCENTAGE') {
                double calculatedBonus = paymentAmount * (bonusValue / 100);
                requestData['bonus'] = calculatedBonus;
              } else {
                requestData['bonus'] = bonusValue;
              }
            }
          }
        }

        final paymentResponse = await _repository.processPayment(
          response.qrCode.hash,
          paymentAmount,
          additionalData: requestData,
        );

        // Create transaction object
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
