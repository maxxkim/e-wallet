import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:zippy/domain/model/settings/biometric_setting_model.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();

  bool _isAuthenticating = false;

  BiometricAuthService._internal();

  void _logEvent(String message) {
    LoggerService().info('🔐 BIOMETRIC SERVICE: $message');
  }

  Future<bool> isBiometricAvailable() async {
    try {
      _logEvent('Checking if biometrics are available');
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      _logEvent(
          'canAuthenticateWithBiometrics: $canAuthenticateWithBiometrics');
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      _logEvent('canAuthenticate (includes device support): $canAuthenticate');
      return canAuthenticate;
    } on PlatformException catch (e) {
      _logEvent('❌ Error checking biometric availability: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      _logEvent('Available biometrics: $biometrics');
      return biometrics;
    } on PlatformException catch (e) {
      _logEvent('❌ Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Authenticate to access your wallet',
  }) async {
    if (_isAuthenticating) {
      _logEvent(
          'Authentication already in progress, skipping duplicate request');
      return false;
    }

    _isAuthenticating = true;

    try {
      _logEvent('Starting biometric authentication: "$localizedReason"');
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        _logEvent("Biometrics not available on this device");
        _isAuthenticating = false;
        return false;
      }

      _logEvent('Calling _localAuth.authenticate()');
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );

      _logEvent('Authentication result: $result');
      _isAuthenticating = false;
      return result;
    } on PlatformException catch (e) {
      _logEvent("❌ Biometric authentication error: $e");
      _isAuthenticating = false;

      if (e.code == auth_error.notAvailable) {
        _logEvent("Biometrics not available on this device");
      } else if (e.code == auth_error.notEnrolled) {
        _logEvent("No biometrics enrolled on this device");
      } else if (e.code == auth_error.lockedOut) {
        _logEvent(
            "Biometric authentication locked out due to too many attempts");
      } else if (e.code == auth_error.permanentlyLockedOut) {
        _logEvent("Biometric authentication permanently locked out");
      }

      return false;
    } catch (e) {
      _logEvent("❌ Unexpected error during biometric auth: $e");
      _isAuthenticating = false;
      return false;
    }
  }

  // PIN Authentication Methods
  Future<bool> setPinCode(String pin) async {
    try {
      _logEvent('Setting PIN code');
      final settings = await getBiometricSettings();
      final updatedSettings = settings.copyWith(
        pinEnabled: true,
        pinCode: pin,
      );
      await saveBiometricSettings(updatedSettings);
      return true;
    } catch (e) {
      _logEvent('❌ Error setting PIN code: $e');
      return false;
    }
  }

  Future<bool> verifyPinCode(String pin) async {
    try {
      _logEvent('Verifying PIN code');
      final settings = await getBiometricSettings();
      if (!settings.pinEnabled || settings.pinCode == null) {
        _logEvent('PIN authentication not set up');
        return false;
      }
      return settings.pinCode == pin;
    } catch (e) {
      _logEvent('❌ Error verifying PIN code: $e');
      return false;
    }
  }

  Future<bool> isPinEnabled() async {
    final settings = await getBiometricSettings();
    return settings.pinEnabled;
  }

  Future<bool> authenticateWithPin(String pin) async {
    return await verifyPinCode(pin);
  }

  Future<void> disablePin() async {
    try {
      _logEvent('Disabling PIN authentication');
      final settings = await getBiometricSettings();
      final updatedSettings = settings.copyWith(
        pinEnabled: false,
        pinCode: null,
      );
      await saveBiometricSettings(updatedSettings);
    } catch (e) {
      _logEvent('❌ Error disabling PIN: $e');
    }
  }

  // Original methods with PIN support added
  Future<void> saveBiometricSettings(BiometricSettings settings) async {
    _logEvent('Saving biometric settings: $settings');
    final settingsJson = jsonEncode(settings.toJson());
    await _secureStorage.write(key: 'biometric_settings', value: settingsJson);
    _logEvent('Biometric settings saved successfully');
  }

  Future<BiometricSettings> getBiometricSettings() async {
    _logEvent('Getting biometric settings');
    final settingsJson = await _secureStorage.read(key: 'biometric_settings');

    if (settingsJson == null) {
      _logEvent(
          'No settings found in storage, checking if biometrics are available');
      final canUseBiometrics = await isBiometricAvailable();
      _logEvent('Creating default settings with enabled=$canUseBiometrics');
      return BiometricSettings(enabled: canUseBiometrics);
    }

    try {
      final settings = BiometricSettings.fromJson(jsonDecode(settingsJson));
      _logEvent(
          'Retrieved settings: enabled=${settings.enabled}, timeout=${settings.lockTimeoutSeconds}s, pinEnabled=${settings.pinEnabled}');
      return settings;
    } catch (e) {
      _logEvent('❌ Error parsing settings JSON: $e');
      return const BiometricSettings();
    }
  }

  Future<void> updateBiometricSetting({
    bool? enabled,
    int? lockTimeoutSeconds,
    bool? requireOnAppStart,
    bool? requireForTransactions,
    bool? pinEnabled,
    String? pinCode,
  }) async {
    _logEvent(
        'Updating biometric settings: enabled=$enabled, lockTimeout=$lockTimeoutSeconds, '
        'requireOnAppStart=$requireOnAppStart, requireForTransactions=$requireForTransactions, '
        'pinEnabled=$pinEnabled');

    final currentSettings = await getBiometricSettings();
    final updatedSettings = currentSettings.copyWith(
      enabled: enabled,
      lockTimeoutSeconds: lockTimeoutSeconds,
      requireOnAppStart: requireOnAppStart,
      requireForTransactions: requireForTransactions,
      pinEnabled: pinEnabled,
      pinCode: pinCode,
    );

    await saveBiometricSettings(updatedSettings);
    _logEvent('Settings updated successfully');
  }

  Future<void> enableBiometrics() async {
    _logEvent('Attempting to enable biometrics');
    final canAuthenticate = await isBiometricAvailable();

    if (!canAuthenticate) {
      _logEvent('Cannot enable biometrics - not available on device');
      return;
    }

    final authenticated = await authenticateWithBiometrics();
    if (authenticated) {
      _logEvent('Authentication successful, enabling biometrics');
      await updateBiometricSetting(enabled: true);
    } else {
      _logEvent('Authentication failed, not enabling biometrics');
    }
  }

  Future<void> disableBiometrics() async {
    _logEvent('Attempting to disable biometrics');
    final isEnabled = await isBiometricsEnabled();

    if (isEnabled) {
      final authenticated = await authenticateWithBiometrics();
      if (authenticated) {
        _logEvent('Authentication successful, disabling biometrics');
        await updateBiometricSetting(enabled: false);
      } else {
        _logEvent('Authentication failed, not disabling biometrics');
      }
    } else {
      _logEvent('Biometrics already disabled');
      await updateBiometricSetting(enabled: false);
    }
  }

  Future<bool> isBiometricsEnabled() async {
    final settings = await getBiometricSettings();
    _logEvent('Checking if biometrics are enabled: ${settings.enabled}');
    return settings.enabled;
  }

  Future<bool> checkAppLock() async {
    _logEvent('Checking app lock');
    final settings = await getBiometricSettings();

    // First check if PIN is enabled
    if (settings.pinEnabled) {
      _logEvent('PIN is enabled, authentication will be handled by PIN screen');
      return false; // Return false to show the PIN lock screen
    }

    // If no PIN, check biometrics
    if (!settings.enabled) {
      _logEvent('Biometrics not enabled, skipping app lock check');
      return true;
    }

    _logEvent('Biometrics enabled, requesting authentication');
    return await authenticateWithBiometrics();
  }

  Future<bool> shouldLockApp(DateTime pausedTime) async {
    _logEvent('Checking if app should be locked after being paused');
    final settings = await getBiometricSettings();

    // If neither PIN nor biometrics are enabled, don't lock
    if (!settings.enabled && !settings.pinEnabled) {
      _logEvent('Neither biometrics nor PIN enabled, should not lock app');
      return false;
    }

    final now = DateTime.now();
    final backgroundDuration = now.difference(pausedTime).inSeconds;
    final shouldLock = backgroundDuration >= settings.lockTimeoutSeconds;
    _logEvent(
        'App was paused for $backgroundDuration seconds, timeout is ${settings.lockTimeoutSeconds}s, should lock: $shouldLock');
    return shouldLock;
  }
}
