import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';
import 'package:zippy/presentation/screen/auth/helpers/phone_mask_helper.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SecureStorageService _secureStorage = SecureStorageService();
  CountryModel? _currentCountryModel;

  AuthCubit(this._authRepository)
      : super(AuthStateLoaded(
          termsAccepted: false,
          codeStatus: CodeStatus.none,
          shakeKey: false,
          userId: "",
          phone: "",
        ));

  void _logEvent(String message) {
    final logger = LoggerService();
    logger.info('🔐 AUTH: $message');
  }

  Future<void> verifyCode(String code) async {
    if (state is AuthStateLoaded) {
      final currentState = state as AuthStateLoaded;
      try {
        _logEvent('📱 Attempting to verify code: $code');

        final AuthVerify authVerify = await _authRepository.verifyAuth(
          code,
          currentState.phone,
          currentState.userId,
        );

        if (authVerify.isVerified) {
          _logEvent('✅ Code verified successfully! Token received!');

          // Store tokens
          if (authVerify.accessToken != null) {
            await _secureStorage.saveAccessToken(authVerify.accessToken!);
            _logEvent(
                '💾 Access token saved (${authVerify.accessToken!.substring(0, 10)}...)');
          } else {
            _logEvent('⚠️ No access token received!');
          }

          if (authVerify.refreshToken != null) {
            await _secureStorage.saveRefreshToken(authVerify.refreshToken!);
            _logEvent('💾 Refresh token saved');
          } else {
            _logEvent('⚠️ No refresh token received!');
          }

          // Save login time
          await _secureStorage.saveLastLoginTime();

          // Save country model for phone mask
          if (currentState.authInitiateResponse != null &&
              _currentCountryModel != null) {
            await PhoneMaskHelper.savePhoneMaskInfo(_currentCountryModel!);
            _logEvent(
                '📞 Phone mask info saved for country: ${_currentCountryModel!.code}');
          }

          emit(currentState.copyWith(
            codeStatus: CodeStatus.correct,
            authVerifyResponse: authVerify,
            shakeKey: false,
          ));

          // Test if the token works
          try {
            final isTokenValid =
                await _authRepository.verifyToken(authVerify.accessToken ?? '');
            _logEvent(isTokenValid
                ? '✅ Token validation successful!'
                : '❌ Token validation failed!');
          } catch (e) {
            _logEvent('❌ Token validation error: $e');
          }
        } else {
          _logEvent('❌ Code verification failed');
          emit(currentState.copyWith(
            codeStatus: CodeStatus.invalid,
            authVerifyResponse: authVerify,
            shakeKey: true,
          ));
        }
      } catch (e) {
        _logEvent('❌ Error during code verification: $e');
        emit(currentState.copyWith(
          codeStatus: CodeStatus.invalid,
          shakeKey: true,
        ));
      }
    }
  }

  static Future<AuthCubit> create(
      AuthRepository authRepository, String phone, String countryCode,
      {CountryModel? countryModel}) async {
    final cubit = AuthCubit(authRepository);
    await cubit.loadData(phone, countryCode, countryModel: countryModel);
    return cubit;
  }

  Future<void> loadData(String phone, String countryCode,
      {CountryModel? countryModel}) async {
    try {
      // Store the country model if provided
      if (countryModel != null) {
        _currentCountryModel = countryModel;
      }

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
