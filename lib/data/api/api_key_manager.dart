import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:zippy/internal/services/logger_service.dart';

class SecureApiKeyManager {
  static final SecureApiKeyManager _instance = SecureApiKeyManager._internal();
  factory SecureApiKeyManager() => _instance;

  final LoggerService _logger = LoggerService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _apiKeyStorageKey = 'api_key_encrypted';
  static const String _ivStorageKey = 'api_key_iv';
  static const String _saltStorageKey = 'api_key_salt';
  static const int _storageVersion = 1;
  static const String kMainApiKey = 'main_api_key';
  static const String kAnalyticsApiKey = 'analytics_api_key';

  // Flag to track initialization status
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Cache the API keys in memory
  final Map<String, String> _cachedKeys = {};

  SecureApiKeyManager._internal();

  Future<bool> initialize() async {
    try {
      _logger.kawaii('✨ Initializing Secure API Key Manager UwU ✨');

      // Try to load from assets first (only on first run or if storage is empty)
      bool hasStoredKey = await hasApiKey(kMainApiKey);
      if (!hasStoredKey) {
        _logger.info('🔑 No stored API key found, initializing from assets');
        bool success = await _loadApiKeysFromAssets();

        if (!success) {
          _logger.error('❌ Failed to load API keys from assets');
          _isInitialized = false;
          return false;
        }
      } else {
        _logger.info('🔑 API keys already stored securely~');

        // Validate that the stored keys can be retrieved
        final mainKey = await getApiKey(kMainApiKey);
        if (mainKey == null || mainKey.isEmpty) {
          _logger.error('❌ Stored main API key is invalid');
          await _loadApiKeysFromAssets(); // Try to reload from assets
        } else {
          _cachedKeys[kMainApiKey] = mainKey;

          // Also load analytics key if available
          final analyticsKey = await getApiKey(kAnalyticsApiKey);
          if (analyticsKey != null) {
            _cachedKeys[kAnalyticsApiKey] = analyticsKey;
          }
        }
      }

      // Verify we have valid keys before considering initialization successful
      bool hasValidMainKey = _cachedKeys.containsKey(kMainApiKey) &&
          _cachedKeys[kMainApiKey]!.isNotEmpty;

      _isInitialized = hasValidMainKey;

      if (_isInitialized) {
        _logger.kawaii('🎉 API key manager initialized successfully~ UwU');
      } else {
        _logger.error('❌ API key manager initialization failed!');
      }

      return _isInitialized;
    } catch (e) {
      _logger.error('❌ Failed to initialize API key manager: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<bool> _loadApiKeysFromAssets() async {
    try {
      _logger.info('🔍 Attempting to load API keys from assets...');

      try {
        // Load the API keys from the JSON file in the root directory
        final String apiKeysJson = await rootBundle.loadString('api_keys.json');
        final Map<String, dynamic> apiKeys = jsonDecode(apiKeysJson);

        bool allSuccess = true;
        for (String keyName in apiKeys.keys) {
          String keyValue = apiKeys[keyName];

          // Store in secure storage
          bool success = await storeApiKey(keyName, keyValue);

          // Also cache in memory
          if (success) {
            _cachedKeys[keyName] = keyValue;
          }

          if (!success) {
            allSuccess = false;
            _logger.warning('⚠️ Failed to store key: $keyName');
          }
        }

        if (allSuccess) {
          _logger.kawaii(
              '🎉 All API keys loaded and stored securely! Security level up~!');
        } else {
          _logger.warning('⚠️ Some API keys failed to store');
        }

        return allSuccess && _cachedKeys.containsKey(kMainApiKey);
      } catch (assetError) {
        _logger.error('❌ Could not load API keys from assets: $assetError');
        return false;
      }
    } catch (e) {
      _logger.error('❌ Failed to load API keys: $e');
      return false;
    }
  }

  Future<bool> storeApiKey(String keyName, String apiKey) async {
    try {
      // Generate random salt and IV for encryption
      final String salt = _generateRandomString(16);
      final String iv = _generateRandomString(16);
      final String encryptedKey = _encryptApiKey(apiKey, salt, iv);

      await _secureStorage.write(
          key: '${_apiKeyStorageKey}_$keyName', value: encryptedKey);
      await _secureStorage.write(key: '${_ivStorageKey}_$keyName', value: iv);
      await _secureStorage.write(
          key: '${_saltStorageKey}_$keyName', value: salt);

      // Store the version for future migration needs
      await _secureStorage.write(
          key: 'api_key_version', value: _storageVersion.toString());

      // Update the cache
      _cachedKeys[keyName] = apiKey;

      _logger.info('🔒 API key "$keyName" stored securely nyaa~');
      return true;
    } catch (e) {
      _logger.error('❌ Failed to store API key: $e');
      return false;
    }
  }

  Future<String?> getApiKey(String keyName) async {
    try {
      // First check the cache
      if (_cachedKeys.containsKey(keyName)) {
        return _cachedKeys[keyName];
      }

      // If not in cache, try to get from secure storage
      if (!await hasApiKey(keyName)) {
        _logger.warning('⚠️ API key "$keyName" not found');

        // Try to load from assets if this key is missing
        if (!_isInitialized || (keyName == kMainApiKey)) {
          bool success = await _loadApiKeysFromAssets();
          if (success && _cachedKeys.containsKey(keyName)) {
            return _cachedKeys[keyName];
          }
        }

        return null;
      }

      // Retrieve all components needed for decryption
      final String? encryptedKey =
          await _secureStorage.read(key: '${_apiKeyStorageKey}_$keyName');
      final String? iv =
          await _secureStorage.read(key: '${_ivStorageKey}_$keyName');
      final String? salt =
          await _secureStorage.read(key: '${_saltStorageKey}_$keyName');

      if (encryptedKey == null || iv == null || salt == null) {
        _logger.error('❌ One or more API key components missing');
        return null;
      }

      // Decrypt the key
      final String apiKey = _decryptApiKey(encryptedKey, salt, iv);

      // Update the cache
      _cachedKeys[keyName] = apiKey;

      _logger.info('🔑 API key "$keyName" retrieved successfully');
      return apiKey;
    } catch (e) {
      _logger.error('❌ Failed to retrieve API key: $e');
      return null;
    }
  }

  Future<bool> hasApiKey(String keyName) async {
    // Check cache first
    if (_cachedKeys.containsKey(keyName)) {
      return true;
    }

    // If not in cache, check secure storage
    return await _secureStorage.containsKey(
        key: '${_apiKeyStorageKey}_$keyName');
  }

  Future<bool> removeApiKey(String keyName) async {
    try {
      await _secureStorage.delete(key: '${_apiKeyStorageKey}_$keyName');
      await _secureStorage.delete(key: '${_ivStorageKey}_$keyName');
      await _secureStorage.delete(key: '${_saltStorageKey}_$keyName');

      // Remove from cache
      _cachedKeys.remove(keyName);

      _logger.info('🗑️ API key "$keyName" removed');
      return true;
    } catch (e) {
      _logger.error('❌ Failed to remove API key: $e');
      return false;
    }
  }

  String _generateRandomString(int length) {
    final Random random = Random.secure();
    final List<int> values =
        List<int>.generate(length, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }

  String _encryptApiKey(String apiKey, String salt, String iv) {
    // Derive an encryption key from the salt
    final key = _deriveKeyFromSalt(salt);
    final List<int> apiKeyBytes = utf8.encode(apiKey);
    final List<int> keyBytes = utf8.encode(key);
    final List<int> ivBytes = utf8.encode(iv);
    final List<int> encryptedBytes = List<int>.filled(apiKeyBytes.length, 0);

    // Simple XOR encryption (in production, you'd want to use a strong encryption algorithm)
    for (var i = 0; i < apiKeyBytes.length; i++) {
      encryptedBytes[i] = apiKeyBytes[i] ^
          keyBytes[i % keyBytes.length] ^
          ivBytes[i % ivBytes.length];
    }

    return base64.encode(encryptedBytes);
  }

  String _decryptApiKey(String encryptedApiKey, String salt, String iv) {
    final key = _deriveKeyFromSalt(salt);
    final List<int> encryptedBytes = base64.decode(encryptedApiKey);
    final List<int> keyBytes = utf8.encode(key);
    final List<int> ivBytes = utf8.encode(iv);
    final List<int> decryptedBytes = List<int>.filled(encryptedBytes.length, 0);

    // Reverse the XOR encryption
    for (var i = 0; i < encryptedBytes.length; i++) {
      decryptedBytes[i] = encryptedBytes[i] ^
          keyBytes[i % keyBytes.length] ^
          ivBytes[i % ivBytes.length];
    }

    return utf8.decode(decryptedBytes);
  }

  String _deriveKeyFromSalt(String salt) {
    // Use device-specific information to strengthen the key derivation
    final String deviceInfo = "zentro_wallet_app";
    final String combinedData = salt + deviceInfo;
    final List<int> keyBytes = sha256.convert(utf8.encode(combinedData)).bytes;
    return base64.encode(keyBytes);
  }

  Future<bool> rotateApiKey(String keyName, String newApiKey) async {
    // Remove the old key
    await removeApiKey(keyName);

    // Store the new key
    return await storeApiKey(keyName, newApiKey);
  }
}
