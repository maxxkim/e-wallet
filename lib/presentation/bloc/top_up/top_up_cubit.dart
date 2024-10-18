import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/domain/state/top_up/top_up_state.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';

class TopUpCubit extends Cubit<TopUpState> {
  final TopUpRepository _topUpRepository;

  TopUpCubit(this._topUpRepository) : super(TopUpState());

  Future<void> getTopUp({
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
      final TopUp topUp = await _topUpRepository.getTopUp(
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

      print(topUp.status);

      emit(TopUpState(message: "Top-up successful", isSuccess: true));
    } catch (e) {
      emit(TopUpState(message: "Error during top-up: $e", isSuccess: false));
    }
  }
}