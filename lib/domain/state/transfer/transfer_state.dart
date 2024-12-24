abstract class TransferState {}

class TransferStateLoading extends TransferState {}

class TransferStateLoaded extends TransferState {}

class TransferStateSuccess extends TransferState {}

class TransferStateError extends TransferState {
  final String errorMessage;
  final bool isRecipientNotFound;

  TransferStateError({
    required this.errorMessage,
    this.isRecipientNotFound = false,
  });
}
