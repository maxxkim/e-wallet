import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/events/transaction_events.dart';
import 'package:zippy/internal/application.dart'; // Import to access appNavigatorKey

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
    emit(TransferStateLoading());
    try {
      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));
      final transferInitiate = await transferRepository.initiateTransfer(data);

      // Create a transaction object from the response
      final transaction = Transaction(
        id: transferInitiate.transferHash,
        title: "Transfer to ${data['recipient']}",
        date: DateTime.now(),
        status: "completed",
        currency: "CLP",
        type: "payout",
        amount: data['amount'] is num ? data['amount'].toDouble() : 0.0,
      );

      // Refresh dashboard data
      _refreshDashboard();

      // Fire transaction created event
      TransactionEventBus().fire(TransactionEvent(
        type: TransactionEventType.created,
        transaction: transaction,
      ));

      emit(TransferStateSent(
        transferDetails: {
          'transferHash': transferInitiate.transferHash,
          'status': transferInitiate.status,
          'wallet': transferInitiate.wallet,
        },
        transaction: transaction,
      ));
    } catch (e) {
      final errorMessage = _handleError(e);
      emit(TransferStateError(
          errorMessage: errorMessage,
          isRecipientNotFound:
              errorMessage.contains('Recipient user not found')));
    }
  }

  void _refreshDashboard() {
    try {
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        context.read<DashboardCubit>().loadData();
      }
    } catch (_) {
      // Handle error silently
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
