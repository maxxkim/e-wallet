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

  AuthStateLoaded copyWith({
    bool? termsAccepted,
    CodeStatus? codeStatus,
    String? userId,
    String? phone,
    bool? shakeKey,
    AuthInitiate? authInitiateResponse,
    AuthVerify? authVerifyResponse,
  }) {
    return AuthStateLoaded(
      termsAccepted: termsAccepted ?? this.termsAccepted,
      codeStatus: codeStatus ?? this.codeStatus,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      shakeKey: shakeKey ?? this.shakeKey,
      authInitiateResponse: authInitiateResponse ?? this.authInitiateResponse,
      authVerifyResponse: authVerifyResponse ?? this.authVerifyResponse,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateLoaded &&
          runtimeType == other.runtimeType &&
          termsAccepted == other.termsAccepted &&
          codeStatus == other.codeStatus &&
          userId == other.userId &&
          phone == other.phone &&
          shakeKey == other.shakeKey;

  @override
  int get hashCode =>
      termsAccepted.hashCode ^
      codeStatus.hashCode ^
      userId.hashCode ^
      phone.hashCode ^
      shakeKey.hashCode;
}

class AuthStateError extends AuthState {
  final String errorMessage;

  AuthStateError({
    required this.errorMessage,
  });
}
