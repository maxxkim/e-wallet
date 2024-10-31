import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  late Timer _timer;

  SessionCubit() : super(Unauthenticated()) {
    checkAuthentication();
    _startAuthenticationTimer();
  }

  void _startAuthenticationTimer() {
    const duration =
        Duration(seconds: 300); // Устанавливаем интервал в 30 секунд
    _timer = Timer.periodic(duration, (timer) {
      checkAuthentication();
    });
  }

  Future<void> checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

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
