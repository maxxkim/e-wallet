abstract class TransferState {}

class TransferStateLoading extends TransferState {}

class TransferStateLoaded extends TransferState {}

class TransferStateSent extends TransferState {
  final Map<String, dynamic> transferDetails;
  TransferStateSent({required this.transferDetails});
}

class TransferStateError extends TransferState {
  final String errorMessage;
  final bool isRecipientNotFound;

  TransferStateError({
    required this.errorMessage,
    this.isRecipientNotFound = false,
  });
}
