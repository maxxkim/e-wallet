import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  late Timer _timer;

  SessionCubit(
    this._authRepository,
  ) : super(Unauthenticated()) {
    checkAuthentication();
    _startAuthenticationTimer();
  }

  void _startAuthenticationTimer() async {
    const duration = Duration(seconds: 30);
    _timer = Timer.periodic(duration, (timer) async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        try {
          final String refreshToken = prefs.getString('refreshToken') ?? "";
          final AuthRefresh authRefresh =
              await _authRepository.refreshAuth(refreshToken);

          await prefs.setString('accessToken', authRefresh.accessToken ?? '');
          await prefs.setString('refreshToken', authRefresh.refreshToken ?? '');
          checkAuthentication();
        } catch (e) {
          await prefs.setString('accessToken', '');
          await prefs.setString('accessToken', '');
          print('Failed to refresh auth token');
        } // Проверяем аутентификацию после обновления токена
      } catch (e) {
        print(' No access token stored');
      }
    });
  }

  Future<void> checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');
    final String? refreshToken = prefs.getString('refreshToken');
    print(refreshToken);
    if (accessToken != null && accessToken.isNotEmpty) {
      emit(Authenticated(accessToken));
    } else {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _timer.cancel(); // Отменяем таймер при закрытии cubit
    return super.close();
  }
}
