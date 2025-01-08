import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';

class QrPaymentCubit extends Cubit<QrPaymentState> {
  final QrPaymentRepository _repository;

  QrPaymentCubit(this._repository) : super(QrPaymentInitial());

  void startScanning() {
    emit(QrPaymentScanning());
  }

  Future<void> processQrCode(String code) async {
    try {
      emit(QrPaymentLoading());
      final response = await _repository.checkQrCode(code);
      emit(QrPaymentScanSuccess(qrPaymentResponse: response));
    } catch (e) {
      emit(QrPaymentScanError(e.toString()));
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
        emit(QrPaymentProcessError(e.toString()));
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
