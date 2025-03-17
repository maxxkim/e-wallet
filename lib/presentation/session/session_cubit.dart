import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';
import 'package:zippy/presentation/session/session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage = SecureStorageService();
  Timer? _timer;

  SessionCubit(this._authRepository) : super(InitialLoading()) {
    _initTimer();
  }

  void _initTimer() {
    _timer = Timer.periodic(const Duration(minutes: 5), (_) {
      checkAuthentication();
    });
  }

  Future<void> checkAuthentication() async {
    if (isClosed) return;

    emit(InitialLoading());

    try {
      final String? accessToken = await _secureStorage.getAccessToken();

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
            // Try to refresh token
            await _tryRefreshToken();
          }
        }
      } catch (e) {
        if (!isClosed) {
          await _tryRefreshToken();
        }
      }
    } catch (e) {
      if (!isClosed) emit(Unauthenticated());
    }
  }

  Future<void> _tryRefreshToken() async {
    try {
      emit(RefreshingTokens());
      final refreshToken = await _secureStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        await _secureStorage.clearAllTokens();
        emit(Unauthenticated());
        return;
      }

      final authRefresh = await _authRepository.refreshAuth(refreshToken);

      if (authRefresh.accessToken != null && authRefresh.refreshToken != null) {
        await _secureStorage.saveAccessToken(authRefresh.accessToken!);
        await _secureStorage.saveRefreshToken(authRefresh.refreshToken!);
        emit(Authenticated(authRefresh.accessToken!));
      } else {
        await _secureStorage.clearAllTokens();
        emit(Unauthenticated());
      }
    } catch (e) {
      await _secureStorage.clearAllTokens();
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    if (isClosed) return;
    try {
      await _secureStorage.clearAllTokens();
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
