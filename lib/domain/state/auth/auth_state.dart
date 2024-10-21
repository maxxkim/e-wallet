import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

abstract class AuthState {}

class AuthStateLoaded extends AuthState {
  final bool codeSent;
  final String? phoneNumber;
  final String verificationCode;

  AuthStateLoaded({
    required this.codeSent,
    required this.verificationCode,
    this.phoneNumber,
  });

  // Implementing the copyWith method
  AuthStateLoaded copyWith({
  required final bool codeSent,
  required final String verificationCode,
  final String? phoneNumber,
  }) {
    return AuthStateLoaded(
      codeSent: codeSent,
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
    );
  }
}

class AuthStateError extends AuthState {
  final String errorMessage;

  AuthStateError({
    required this.errorMessage,
  });
}