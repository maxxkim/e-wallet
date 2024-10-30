import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';

enum CodeStatus { correct, invalid, none }

abstract class AuthState {}

class AuthStateLoaded extends AuthState {
  final bool termsAccepted;
  final CodeStatus codeStatus;
  final String? phone;
  final AuthInitiate? authInitiateResponse;
  final AuthVerify? authVerifyResponse;

  AuthStateLoaded({
    required this.termsAccepted,
    required this.codeStatus,
    this.phone,
    this.authInitiateResponse,
    this.authVerifyResponse,
  });

  // Implementing the copyWith method
  AuthStateLoaded copyWith({
    required final bool termsAccepted,
    required final CodeStatus codeStatus,
    final String? phone,
    final AuthInitiate? authInitiateResponse,
    final AuthVerify? authVerifyResponse,
  }) {
    return AuthStateLoaded(
      termsAccepted: termsAccepted,
      codeStatus: codeStatus,
      phone: phone,
      authInitiateResponse: authInitiateResponse,
      authVerifyResponse: authVerifyResponse,
    );
  }
}

class AuthStateError extends AuthState {
  final String errorMessage;

  AuthStateError({
    required this.errorMessage,
  });
}
