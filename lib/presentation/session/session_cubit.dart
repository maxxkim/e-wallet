import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  late Timer _timer;

  SessionCubit(this._authRepository) : super(InitialLoading()) {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    // Start with initial loading state
    if (state is! InitialLoading) {
      emit(InitialLoading());
    }

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? accessToken = prefs.getString('accessToken');

      if (accessToken != null && accessToken.isNotEmpty) {
        final bool isValid = await _authRepository.verifyToken(accessToken);
        if (isValid) {
          emit(Authenticated(accessToken));
        } else {
          await prefs.remove('accessToken');
          emit(Unauthenticated());
        }
      } else {
        await prefs.remove('accessToken');
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _timer.cancel();
    return super.close();
  }
}
