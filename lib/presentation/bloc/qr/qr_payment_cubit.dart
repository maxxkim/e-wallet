import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';

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
          return 'Connection timeout occurred';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'An unknown error occurred';
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
        final paymentAmount = response.qrCode.type == 'FIXED'
            ? response.qrCode.amount
            : double.parse(amount);
        final paymentResponse = await _repository.processPayment(
          response.qrCode.hash,
          paymentAmount,
        );
        emit(QrPaymentSuccess(paymentResponse: paymentResponse));
      } catch (e) {
        emit(QrPaymentProcessError(_handleError(e)));
        emit(currentState.copyWith(isProcessing: false));
      }
    }
  }

  void resetError() {
    if (state is QrPaymentScanSuccess) {
      final currentState = state as QrPaymentScanSuccess;
      emit(currentState.copyWith(amountError: null));
    }
  }

  void resetScanner() {
    emit(QrPaymentScanning());
  }
}
