import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
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
      // Check if biometrics are available on this device
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
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled ||
          e.code == auth_error.passcodeNotSet) {
        // Biometrics not available or not configured
        return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> enableBiometrics() async {
    await _secureStorage.write(key: 'biometrics_enabled', value: 'true');
  }

  Future<void> disableBiometrics() async {
    await _secureStorage.write(key: 'biometrics_enabled', value: 'false');
  }

  Future<bool> isBiometricsEnabled() async {
    final value = await _secureStorage.read(key: 'biometrics_enabled');
    return value == 'true';
  }

  Future<bool> checkAppLock() async {
    final isEnabled = await isBiometricsEnabled();
    if (!isEnabled) return true; // If not enabled, no need to authenticate

    return await authenticateWithBiometrics();
  }
}
