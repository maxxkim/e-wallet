import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/top_up/top_up_state.dart';

class TopUpCubit extends Cubit<TopUpState> {

  TopUpCubit(read) : super(TopUpState());

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
      emit(TopUpState(message: "Top-up successful", isSuccess: true));
    } catch (e) {
      emit(TopUpState(message: "Error during top-up: $e", isSuccess: false));
    }
  }
}