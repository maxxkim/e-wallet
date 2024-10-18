// ignore_for_file: non_constant_identifier_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/withdraw/withdraw_repository.dart';
import 'package:zippy/domain/state/withdraw/withdraw_state.dart';

class WithdrawCubit extends Cubit<WithdrawState> {
  final WithdrawRepository _WithdrawRepository;

  WithdrawCubit(this._WithdrawRepository) : super(WithdrawState());

  Future<void> getWithdraw({
    required String merchantId,
    required String transactionId,
    required String country,
    required String currency,
    required String payMethod,
    required String documentId,
    required String amount,
    required String email,
    required String name,
    required String timestamp,
    String? payinExpirationTime,
    required String urlOk,
    required String urlError,
    required String objData,
  }) async {
    try {
      await _WithdrawRepository.getWithdraw(
        merchantId: merchantId,
        transactionId: transactionId,
        country: country,
        currency: currency,
        payMethod: payMethod,
        documentId: documentId,
        amount: amount,
        email: email,
        name: name,
        timestamp: timestamp,
        payinExpirationTime: payinExpirationTime,
        urlOk: urlOk,
        urlError: urlError,
        objData: objData,
      );


      emit(WithdrawState(message: "Top-up successful", isSuccess: true));
    } catch (e) {
      emit(WithdrawState(message: "Error during top-up: $e", isSuccess: false));
    }
  }
}