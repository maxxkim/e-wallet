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
      final transferInitiate = await transferRepository.initiateTransfer(data);
      emit(TransferStateSent(transferDetails: {
        'transferHash': transferInitiate.transferHash,
        'status': transferInitiate.status,
        'wallet': transferInitiate.wallet,
      }));
    } catch (e) {
      final errorMessage = _handleError(e);
      emit(TransferStateError(
          errorMessage: errorMessage,
          isRecipientNotFound:
              errorMessage.contains('Recipient user not found')));
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['status'] == 'error' &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection error UwU. Please try again!';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded >w<';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded nyaa~';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled ~(=^･ω･^)';
        default:
          return 'An unknown error occurred ><';
      }
    }
    return error.toString();
  }
}
