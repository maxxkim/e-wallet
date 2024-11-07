import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  late Timer _timer;

  SessionCubit(this._authRepository) : super(Unauthenticated()) {
    checkAuthentication();
  }

  Future<void> checkAuthentication() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? accessToken = prefs.getString('accessToken');

    if (accessToken != null && accessToken.isNotEmpty) {
      if (await _authRepository.verifyToken(accessToken)) {
        emit(Authenticated(accessToken));
      } else {
        prefs.remove('accessToken');
        emit(Unauthenticated());
      }
    } else {
      prefs.remove('accessToken');
      emit(Unauthenticated());
    }
  }

  @override
  Future<void> close() {
    _timer.cancel(); // Cancel the timer when closing the cubit
    return super.close();
  }

  /*void _startAuthenticationTimer() async {
    const duration = Duration(hours: 8); // Adjust the duration as needed
    _timer = Timer.periodic(duration, (timer) async {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final String refreshToken = prefs.getString('refreshToken') ?? "";

        if (refreshToken.isNotEmpty) {
          try {
            emit(RefreshingTokens()); // Emit loading state while refreshing

            final AuthRefresh authRefresh =
                await _authRepository.refreshAuth(refreshToken);
            await prefs.setString('accessToken', authRefresh.accessToken ?? '');
            await prefs.setString(
                'refreshToken', authRefresh.refreshToken ?? '');

            checkAuthentication(); // Check authentication status after updating tokens
          } catch (e) {
            print('Failed to refresh auth token: $e');
            await _handleTokenRefreshFailure(
                prefs); // Handle token refresh failure
          }
        } else {
          print('No refresh token stored');
        }
      } catch (e) {
        print('Error accessing shared preferences: $e');
      }
    });
  }  
  Future<void> _handleTokenRefreshFailure(SharedPreferences prefs) async {
    await prefs.setString('accessToken', '');
    await prefs.setString('refreshToken', '');
    emit(Unauthenticated()); // Emit unauthenticated state on failure
  }
  */
}
