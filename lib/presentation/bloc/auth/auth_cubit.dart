import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository)
      : super(AuthStateLoaded(
          termsAccepted: false,
          codeStatus: CodeStatus.none,
          shakeKey: false,
          userId: "",
          phone: "",
        ));

  Future<void> verifyCode(String code) async {
    if (state is AuthStateLoaded) {
      final currentState = state as AuthStateLoaded;

      try {
        final AuthVerify authVerify = await _authRepository.verifyAuth(
          code,
          currentState.phone,
          currentState.userId,
        );

        if (authVerify.isVerified) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', authVerify.accessToken ?? '');
          await prefs.setString('refreshToken', authVerify.refreshToken ?? '');

          emit(currentState.copyWith(
            codeStatus: CodeStatus.correct,
            authVerifyResponse: authVerify,
            shakeKey: false,
          ));
        } else {
          emit(currentState.copyWith(
            codeStatus: CodeStatus.invalid,
            authVerifyResponse: authVerify,
            shakeKey: true,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          codeStatus: CodeStatus.invalid,
          shakeKey: true,
        ));
      }
    }
  }

  static Future<AuthCubit> create(
      AuthRepository authRepository, String phone, String countryCode) async {
    final cubit = AuthCubit(authRepository);
    await cubit.loadData(phone, countryCode);
    return cubit;
  }

  Future<void> loadData(String phone, String countryCode) async {
    try {
      final AuthInitiate authInitiate =
          await _authRepository.initiateAuth(phone, countryCode);
      emit(AuthStateLoaded(
        phone: phone,
        userId: authInitiate.userId,
        authInitiateResponse: authInitiate,
        termsAccepted: false,
        codeStatus: CodeStatus.none,
        shakeKey: false,
      ));
    } catch (e) {
      emit(AuthStateError(errorMessage: _handleError(e)));
    }
  }

  Future<void> restoreShake() async {
    if (state is AuthStateLoaded) {
      final currentState = state as AuthStateLoaded;
      emit(currentState.copyWith(shakeKey: false));
    }
  }

  Future<void> toggleTerms() async {
    if (state is AuthStateLoaded) {
      final currentState = state as AuthStateLoaded;
      emit(currentState.copyWith(termsAccepted: !currentState.termsAccepted));
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
