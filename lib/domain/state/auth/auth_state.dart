enum CodeStatus {correct, invalid, none}

abstract class AuthState {}

class AuthStateLoaded extends AuthState {
  final bool termsAccepted;
  final CodeStatus codeStatus;
  final String phoneNumber;
  final String verificationCode;

  AuthStateLoaded({
    required this.termsAccepted,
    required this.codeStatus,
    required this.verificationCode,
    required this.phoneNumber,
  });

  // Implementing the copyWith method
  AuthStateLoaded copyWith({
  required final bool termsAccepted,
  required final String verificationCode,
  required final String phoneNumber,
  required final CodeStatus codeStatus,
  }) {
    return AuthStateLoaded(
      termsAccepted: termsAccepted,
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
      codeStatus: codeStatus,
    );
  }
}

class AuthStateError extends AuthState {
  final String errorMessage;

  AuthStateError({
    required this.errorMessage,
  });
}