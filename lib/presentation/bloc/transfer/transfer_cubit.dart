import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';

class TransferCubit extends Cubit<TransferState> {
  final TransferRepository transferRepository;

  TransferCubit(this.transferRepository) : super(TransferStateLoading());

  static Future<TransferCubit> create(
      TransferRepository transferRepository) async {
    final cubit = TransferCubit(transferRepository);
    await cubit.loadData();
    return cubit;
  }

  Future<void> loadData() async {
    try {
      emit(TransferStateLoaded());
    } catch (e) {
      emit(TransferStateError(errorMessage: e.toString()));
    }
  }

  Future<void> initializeTransfer(Map<String, dynamic> data) async {
    try {
      await transferRepository.initiateTransfer(data);
      emit(TransferStateSuccess());
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
          emit(TransferStateError(
            errorMessage: e.toString(),
            isRecipientNotFound: true,
          ));
        } else {
          emit(TransferStateError(errorMessage: e.toString()));
        }
      } else {
        emit(TransferStateError(errorMessage: e.toString()));
      }
    }
  }
}
