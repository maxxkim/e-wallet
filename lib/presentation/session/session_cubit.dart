import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  Timer? _timer;

  SessionCubit(this._authRepository) : super(InitialLoading()) {
    // Don't immediately call checkAuthentication to let tests control the flow
    _initTimer();
  }

  void _initTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      checkAuthentication();
    });
  }

  Future<void> checkAuthentication() async {
    if (isClosed) return; // Prevent emission after closing

    emit(InitialLoading()); // Always emit initial loading first

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken == null || accessToken.isEmpty) {
        if (!isClosed) emit(Unauthenticated());
        return;
      }

      try {
        final bool isValid = await _authRepository.verifyToken(accessToken);
        if (!isClosed) {
          if (isValid) {
            emit(Authenticated(accessToken));
          } else {
            await prefs.remove('accessToken');
            emit(Unauthenticated());
          }
        }
      } catch (e) {
        if (!isClosed) {
          await prefs.remove('accessToken');
          emit(Unauthenticated());
        }
      }
    } catch (e) {
      if (!isClosed) emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    if (isClosed) return;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      if (!isClosed) emit(Unauthenticated());
    } catch (e) {
      if (!isClosed) emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }
}
