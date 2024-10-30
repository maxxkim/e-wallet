import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';

enum CodeStatus { correct, invalid, none }

abstract class AuthState {}

class AuthStateLoaded extends AuthState {
  final bool termsAccepted;
  final CodeStatus codeStatus;
  final String userId;
  final String phone;
  final bool shakeKey;
  final AuthInitiate? authInitiateResponse;
  final AuthVerify? authVerifyResponse;

  AuthStateLoaded({
    required this.termsAccepted,
    required this.codeStatus,
    required this.userId,
    required this.phone,
    required this.shakeKey,
    this.authInitiateResponse,
    this.authVerifyResponse,
  });

  // Implementing the copyWith method
  AuthStateLoaded copyWith({
    bool? termsAccepted,
    CodeStatus? codeStatus,
    String? userId,
    String? phone,
    AuthInitiate? authInitiateResponse,
    AuthVerify? authVerifyResponse,
    bool? shakeKey,
  }) {
    return AuthStateLoaded(
      userId: userId ?? this.userId,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      codeStatus: codeStatus ?? this.codeStatus,
      phone: phone ?? this.phone,
      shakeKey: shakeKey ?? this.shakeKey,
      authInitiateResponse: authInitiateResponse ?? this.authInitiateResponse,
      authVerifyResponse: authVerifyResponse ?? this.authVerifyResponse,
    );
  }
}

class AuthStateError extends AuthState {
  final String errorMessage;

  AuthStateError({
    required this.errorMessage,
  });
}
