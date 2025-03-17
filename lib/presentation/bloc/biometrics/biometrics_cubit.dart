import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/biometrics/biometrics_settings_state.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';

class BiometricSettingsCubit extends Cubit<BiometricSettingsState> {
  final BiometricAuthService _biometricAuthService;

  BiometricSettingsCubit(this._biometricAuthService)
      : super(BiometricSettingsLoading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      emit(BiometricSettingsLoading());

      // Get if biometrics are available on this device
      final isBiometricsAvailable =
          await _biometricAuthService.isBiometricAvailable();

      // Get available biometric types (fingerprint, face, etc)
      final biometricTypes =
          await _biometricAuthService.getAvailableBiometrics();

      // Get current settings from storage
      final settings = await _biometricAuthService.getBiometricSettings();

      emit(BiometricSettingsLoaded(
        settings: settings,
        isBiometricsAvailable: isBiometricsAvailable,
        availableBiometricTypes: biometricTypes,
      ));
    } catch (e) {
      emit(BiometricSettingsError('Failed to load biometric settings: $e'));
    }
  }

  // Enable/disable biometrics
  Future<void> toggleBiometrics(bool enabled) async {
    try {
      await _biometricAuthService.updateBiometricSetting(enabled: enabled);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update biometric settings: $e'));
    }
  }

  // Update lock timeout
  Future<void> updateLockTimeout(int seconds) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          lockTimeoutSeconds: seconds);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update lock timeout: $e'));
    }
  }

  // Toggle require on app start
  Future<void> toggleRequireOnAppStart(bool required) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          requireOnAppStart: required);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update app start setting: $e'));
    }
  }

  // Toggle require for transactions
  Future<void> toggleRequireForTransactions(bool required) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          requireForTransactions: required);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update transactions setting: $e'));
    }
  }

  // Authenticate using biometrics (can be used to test)
  Future<bool> authenticate() async {
    return await _biometricAuthService.authenticateWithBiometrics();
  }
}
