// lib/internal/services/biometric_auth_service.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:zippy/domain/model/settings/biometric_setting_model.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance =
      BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService();

  BiometricAuthService._internal();

  Future<bool> isBiometricAvailable() async {
    try {
      // Check if biometrics or device credentials can be used
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Authenticate to access your wallet',
  }) async {
    try {
      // Check if biometrics are available first
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        print("Biometrics not available on this device (◡﹏◡✿)");
        return false;
      }

      // Use stickyAuth to handle app going to background during authentication
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true, // Show system dialogs for errors
        ),
      );
    } on PlatformException catch (e) {
      print("Biometric authentication error: $e UwU");
      return false;
    } catch (e) {
      print("Unexpected error during biometric auth: $e >.<");
      return false;
    }
  }

  // Save biometric settings to secure storage
  Future<void> saveBiometricSettings(BiometricSettings settings) async {
    final settingsJson = jsonEncode(settings.toJson());
    await _secureStorage.write(key: 'biometric_settings', value: settingsJson);
  }

  // Get biometric settings from secure storage
  Future<BiometricSettings> getBiometricSettings() async {
    final settingsJson = await _secureStorage.read(key: 'biometric_settings');
    if (settingsJson == null) {
      // Set up default settings based on device capabilities
      final canUseBiometrics = await isBiometricAvailable();
      return BiometricSettings(enabled: canUseBiometrics);
    }

    try {
      return BiometricSettings.fromJson(jsonDecode(settingsJson));
    } catch (_) {
      return const BiometricSettings();
    }
  }

  // Update a specific setting
  Future<void> updateBiometricSetting({
    bool? enabled,
    int? lockTimeoutSeconds,
    bool? requireOnAppStart,
    bool? requireForTransactions,
  }) async {
    final currentSettings = await getBiometricSettings();
    final updatedSettings = currentSettings.copyWith(
      enabled: enabled,
      lockTimeoutSeconds: lockTimeoutSeconds,
      requireOnAppStart: requireOnAppStart,
      requireForTransactions: requireForTransactions,
    );
    await saveBiometricSettings(updatedSettings);
  }

  // For backward compatibility
  Future<void> enableBiometrics() async {
    // First check if biometrics are available and prompt authentication
    final canAuthenticate = await isBiometricAvailable();
    if (!canAuthenticate) {
      return;
    }

    // Try to authenticate before enabling
    final authenticated = await authenticateWithBiometrics();
    if (authenticated) {
      await updateBiometricSetting(enabled: true);
    }
  }

  Future<void> disableBiometrics() async {
    // For disabling, we should also authenticate first
    final isEnabled = await isBiometricsEnabled();
    if (isEnabled) {
      final authenticated = await authenticateWithBiometrics();
      if (authenticated) {
        await updateBiometricSetting(enabled: false);
      }
    } else {
      await updateBiometricSetting(enabled: false);
    }
  }

  Future<bool> isBiometricsEnabled() async {
    final settings = await getBiometricSettings();
    return settings.enabled;
  }

  Future<bool> checkAppLock() async {
    final isEnabled = await isBiometricsEnabled();
    if (!isEnabled) return true; // Skip authentication if biometrics disabled

    return await authenticateWithBiometrics();
  }

  // Check if we should lock the app based on settings and time in background
  Future<bool> shouldLockApp(DateTime pausedTime) async {
    final settings = await getBiometricSettings();
    if (!settings.enabled) return false;

    final now = DateTime.now();
    final backgroundDuration = now.difference(pausedTime).inSeconds;
    return backgroundDuration >= settings.lockTimeoutSeconds;
  }
}
