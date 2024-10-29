import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'dart:math';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _AuthRepository;

  AuthCubit(this._AuthRepository)
      : super(AuthStateLoaded(
            termsAccepted: false,
            phoneNumber: generateRandomPhoneNumber(),
            verificationCode: generateRandomFourDigitCode(),
            codeStatus: CodeStatus.none));

  static Future<AuthCubit> create(AuthRepository AuthRepository) async {
    final cubit = AuthCubit(AuthRepository);
    await cubit.loadData();
    return cubit;
  }

  Future<void> loadData() async {
    try {
      if (state is AuthStateLoaded) {
        var currentState = state as AuthStateLoaded;
        {
          emit(AuthStateLoaded(
              termsAccepted: currentState.termsAccepted,
              phoneNumber: currentState.phoneNumber,
              verificationCode: currentState.verificationCode,
              codeStatus: currentState.codeStatus));
        }
      }
    } catch (e) {
      emit(AuthStateError(
        errorMessage: _handleError(e),
      ));
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

  Future<void> verifyCode(String code) async {
    if (state is AuthStateLoaded) {
      var currentState = state as AuthStateLoaded;
      if (currentState.verificationCode == code) {
        emit(AuthStateLoaded(
            termsAccepted: currentState.termsAccepted,
            phoneNumber: currentState.phoneNumber,
            verificationCode: currentState.verificationCode,
            codeStatus: CodeStatus.correct));
      } else {
        emit(AuthStateLoaded(
            termsAccepted: currentState.termsAccepted,
            phoneNumber: currentState.phoneNumber,
            verificationCode: currentState.verificationCode,
            codeStatus: CodeStatus.invalid));
      }
    } else {
      emit(AuthStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  Future<void> toggleTerms() async {
    if (state is AuthStateLoaded) {
      var currentState = state as AuthStateLoaded;
      emit(currentState.copyWith(
          termsAccepted: !currentState.termsAccepted,
          phoneNumber: currentState.phoneNumber,
          verificationCode: currentState.verificationCode,
          codeStatus: currentState.codeStatus));
    } else {
      emit(AuthStateError(
        errorMessage: _handleError(e),
      ));
    }
  }
}

String generateRandomPhoneNumber() {
  Random random = Random();
  int areaCode =
      random.nextInt(900) + 100; // Генерируем код области от 100 до 999
  int centralOfficeCode = random.nextInt(900) +
      100; // Генерируем центральный офисный код от 100 до 999
  int lineNumber =
      random.nextInt(10000); // Генерируем номер линии от 0000 до 9999

  return '+7 ($areaCode) $centralOfficeCode-${lineNumber.toString().padLeft(4, '0')}';
}

String generateRandomFourDigitCode() {
  Random random = Random();
  int code = random.nextInt(10000);
  String res = code.toString().padLeft(4, '0');
  print(res);
  return res; // Возвращаем строку с ведущими нулями
}
