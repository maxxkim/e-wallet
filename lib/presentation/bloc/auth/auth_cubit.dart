import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _AuthRepository;

  AuthCubit(this._AuthRepository) : super(AuthStateLoaded(
    codeSent: false,
    verificationCode: '1111'
  ));

  static Future<AuthCubit> create(AuthRepository AuthRepository) async {
    final cubit = AuthCubit(AuthRepository);
    await cubit.loadData();
    return cubit;
  }

  Future<void> loadData() async {
    try {
      emit(AuthStateLoaded(
          codeSent: false,
          verificationCode: '1111'
      ));
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
}
