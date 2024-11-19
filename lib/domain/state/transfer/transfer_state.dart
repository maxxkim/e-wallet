abstract class TransferState {}

class TransferStateLoading extends TransferState {}

class TransferStateLoaded extends TransferState {}

class TransferStateSent extends TransferState {}

class TransferStateError extends TransferState {
  final String errorMessage;
  TransferStateError({required this.errorMessage});
}
