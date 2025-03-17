import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service to securely store sensitive information.
class SecureStorageService {
  static final SecureStorageService _instance =
      SecureStorageService._internal();
  factory SecureStorageService() => _instance;

  // Initialize with default options
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
      // Use default Android and iOS options
      );

  SecureStorageService._internal();

  // Generic methods for key-value storage
  Future<void> write({required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  Future<bool> containsKey({required String key}) async {
    return await _storage.containsKey(key: key);
  }

  Future<Map<String, String>> readAll() async {
    return await _storage.readAll();
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // Token specific methods
  Future<void> saveAccessToken(String token) async {
    await write(key: 'accessToken', value: token);
  }

  Future<String?> getAccessToken() async {
    return await read(key: 'accessToken');
  }

  Future<void> saveRefreshToken(String token) async {
    await write(key: 'refreshToken', value: token);
  }

  Future<String?> getRefreshToken() async {
    return await read(key: 'refreshToken');
  }

  Future<void> deleteAccessToken() async {
    await delete(key: 'accessToken');
  }

  Future<void> deleteRefreshToken() async {
    await delete(key: 'refreshToken');
  }

  Future<void> clearAllTokens() async {
    await deleteAccessToken();
    await deleteRefreshToken();
  }

  // Last login timestamp
  Future<void> saveLastLoginTime() async {
    await write(
        key: 'last_login_time', value: DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastLoginTime() async {
    final timeStr = await read(key: 'last_login_time');
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  // User settings
  Future<void> saveLocale(String locale) async {
    await write(key: 'selected_locale', value: locale);
  }

  Future<String?> getLocale() async {
    return await read(key: 'selected_locale');
  }

  // Phone mask info
  Future<void> savePhoneMaskInfo(
      String mask, String pattern, String countryCode) async {
    await write(key: 'phone_mask', value: mask);
    await write(key: 'phone_pattern', value: pattern);
    await write(key: 'country_code', value: countryCode);
  }

  Future<String?> getPhoneMask() async {
    return await read(key: 'phone_mask');
  }

  Future<String?> getPhonePattern() async {
    return await read(key: 'phone_pattern');
  }

  Future<String?> getCountryCode() async {
    return await read(key: 'country_code');
  }
}
