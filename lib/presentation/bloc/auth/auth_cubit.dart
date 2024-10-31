import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(
    this._authRepository,
  ) : super(AuthStateLoaded(
          termsAccepted: false,
          codeStatus: CodeStatus.none,
          shakeKey: false,
          userId: "",
          phone: "",
        ));

  static Future<AuthCubit> create(
    AuthRepository authRepository,
    String phone,
  ) async {
    final cubit = AuthCubit(
      authRepository,
    );
    await cubit.loadData(
      phone,
    );
    return cubit;
  }

  Future<void> loadData(String phone) async {
    try {
      final AuthInitiate authInitiate =
          await _authRepository.initiateAuth(phone);
      emit(AuthStateLoaded(
        phone: phone,
        userId: authInitiate.userId,
        authInitiateResponse: authInitiate,
        termsAccepted: false,
        codeStatus: CodeStatus.none,
        shakeKey: false,
      ));
    } catch (e) {
      emit(AuthStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  Future<void> verifyCode(String code) async {
    if (state is AuthStateLoaded) {
      try {
        var currentState = state as AuthStateLoaded;
        final AuthVerify authVerify = await _authRepository.verifyAuth(
          code,
          currentState.phone,
          currentState.userId,
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', authVerify.accessToken ?? '');
        await prefs.setString('refreshToken', authVerify.refreshToken ?? '');
        emit(authVerify.isVerified
            ? currentState.copyWith(
                codeStatus: CodeStatus.correct,
              )
            : currentState.copyWith(
                codeStatus: CodeStatus.invalid,
                shakeKey: true,
              ));
      } catch (e) {
        emit(AuthStateError(errorMessage: _handleError(e)));
      }
    }
  }

  Future<void> restoreShake() async {
    if (state is AuthStateLoaded) {
      try {
        var currentState = state as AuthStateLoaded;
        emit(currentState.copyWith(
          shakeKey: false,
        ));
      } catch (e) {
        emit(AuthStateError(errorMessage: _handleError(e)));
      }
    }
  }

  Future<void> toggleTerms() async {
    if (state is AuthStateLoaded) {
      try {
        var currentState = state as AuthStateLoaded;
        emit(currentState.copyWith(
          termsAccepted: !currentState.termsAccepted,
        ));
      } catch (e) {
        emit(AuthStateError(
          errorMessage: _handleError(e),
        ));
      }
    }
  }
}

String _handleError(dynamic error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Ошибка подключения. Попробуйте еще раз.';
      case DioExceptionType.connectionError:
        return 'Ошибка подключения. Попробуйте еще раз.';
      case DioExceptionType.sendTimeout:
        return 'Время ожидания отправки истекло.';
      case DioExceptionType.receiveTimeout:
        return 'Время ожидания получения ответа истекло.';
      case DioExceptionType.badResponse:
        return 'Ошибка сервера: ${error.response?.statusCode}.';
      case DioExceptionType.badCertificate:
        return 'Ошибка сертификата.';
      case DioExceptionType.cancel:
        return 'Запрос отменен.';
      case DioExceptionType.unknown:
        return 'Произошла неизвестная ошибка.';
    }
  }
  return error.toString();
}
