import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
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
      final transferInitiate = await transferRepository.initiateTransfer(data);
      emit(TransferStateSent(transferDetails: {
        'transferHash': transferInitiate.transferHash,
        'status': transferInitiate.status,
        'wallet': transferInitiate.wallet,
      }));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        emit(TransferStateError(
          errorMessage: 'Recipient not found',
          isRecipientNotFound: true,
        ));
      } else {
        emit(TransferStateError(
          errorMessage: 'Transfer failed: ${e.message}',
        ));
      }
    } catch (e) {
      emit(TransferStateError(errorMessage: e.toString()));
    }
  }
}
