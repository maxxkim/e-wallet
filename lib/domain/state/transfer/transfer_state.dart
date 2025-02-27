import 'package:zippy/domain/model/transaction/transaction_model.dart';

abstract class TransferState {}

class TransferStateLoading extends TransferState {}

class TransferStateLoaded extends TransferState {}

class TransferStateSent extends TransferState {
  final Map<String, dynamic> transferDetails;
  final Transaction transaction;

  TransferStateSent({
    required this.transferDetails,
    required this.transaction,
  });
}

class TransferStateError extends TransferState {
  final String errorMessage;
  final bool isRecipientNotFound;

  TransferStateError({
    required this.errorMessage,
    this.isRecipientNotFound = false,
  });
}
