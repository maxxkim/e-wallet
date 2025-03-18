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

      final isBiometricsAvailable =
          await _biometricAuthService.isBiometricAvailable();

      final biometricTypes =
          await _biometricAuthService.getAvailableBiometrics();

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

  // Biometrics Methods
  Future<void> toggleBiometrics(bool enabled) async {
    try {
      bool success;
      if (enabled) {
        success = await _biometricAuthService.authenticateWithBiometrics(
            localizedReason: 'Authenticate to enable biometric login');
        if (success) {
          await _biometricAuthService.updateBiometricSetting(enabled: true);
          await loadSettings();
        }
      } else {
        success = await _biometricAuthService.authenticateWithBiometrics(
            localizedReason: 'Authenticate to disable biometric login');
        if (success) {
          await _biometricAuthService.updateBiometricSetting(enabled: false);
          await loadSettings();
        }
      }
    } catch (e) {
      emit(BiometricSettingsError('Failed to update biometric settings: $e'));
    }
  }

  Future<void> updateLockTimeout(int seconds) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          lockTimeoutSeconds: seconds);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update lock timeout: $e'));
    }
  }

  Future<void> toggleRequireOnAppStart(bool required) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          requireOnAppStart: required);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update app start setting: $e'));
    }
  }

  Future<void> toggleRequireForTransactions(bool required) async {
    try {
      await _biometricAuthService.updateBiometricSetting(
          requireForTransactions: required);
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to update transactions setting: $e'));
    }
  }

  // PIN Methods
  Future<bool> setPinCode(String pin) async {
    try {
      bool success = await _biometricAuthService.setPinCode(pin);
      if (success) {
        await loadSettings();
        return true;
      }
      return false;
    } catch (e) {
      emit(BiometricSettingsError('Failed to set PIN code: $e'));
      return false;
    }
  }

  Future<void> disablePin() async {
    try {
      await _biometricAuthService.disablePin();
      await loadSettings();
    } catch (e) {
      emit(BiometricSettingsError('Failed to disable PIN: $e'));
    }
  }

  Future<bool> verifyPinCode(String pin) async {
    try {
      return await _biometricAuthService.verifyPinCode(pin);
    } catch (e) {
      emit(BiometricSettingsError('Failed to verify PIN code: $e'));
      return false;
    }
  }

  Future<bool> authenticate() async {
    return await _biometricAuthService.authenticateWithBiometrics();
  }
}
