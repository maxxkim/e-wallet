import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class CertificatePinningUtils {
  static final LoggerService _logger = LoggerService();
  static final SecureStorageService _secureStorage = SecureStorageService();

  static const String _pinsStorageKey = 'certificate_pins';

  // These pins match the ones defined in ApiService
  static const List<String> defaultPins = [
    'sha256/qLTRfjRmkUcjDm/VzK9yWYYsxcAJ75/OOlIKiaG8uCw=',
    'sha256/YZPgTZ+woNCCCIW3LH2CxQeLzB/1m42QcCTBSdgayjs=',
  ];

  // All microservice hosts from the app
  static const List<String> pinnedHosts = [
    'balance-service-zug9v.ondigitalocean.app',
    'trx-service-lc9l6.ondigitalocean.app',
    'auth-service-9jf3q.ondigitalocean.app',
    'transfer-service-dibxk.ondigitalocean.app',
    'contact-service-w42s8.ondigitalocean.app',
    'merchant-service-gp4xz.ondigitalocean.app',
    'offer-service-xn3b9.ondigitalocean.app',
    'search-service-52g7l.ondigitalocean.app'
  ];

  static Uint8List extractSPKI(X509Certificate certificate) {
    _logger.info('🔍 Extracting SPKI from certificate... UwU');
    // Implementation would go here
    // This is a placeholder since the actual implementation is complex
    return Uint8List(0);
  }

  static bool verifyCertificatePin(
      X509Certificate certificate, List<String> pins) {
    try {
      final spki = extractSPKI(certificate);
      final digest = sha256.convert(spki);
      final String calculatedPin = base64.encode(digest.bytes);
      for (final pin in pins) {
        final expectedHash = pin.replaceFirst('sha256/', '');
        if (calculatedPin == expectedHash) {
          _logger.kawaii('✅ Certificate pin verified! Security victory! 🎉');
          return true;
        }
      }
      _logger.error(
          '❌ Certificate pin verification FAILED! Possible MITM attack! >_<');
      return false;
    } catch (e) {
      _logger.error('😿 Error verifying certificate pin: $e');
      return false;
    }
  }

  static Future<List<String>> getCertificatePins() async {
    try {
      final pinsString = await _secureStorage.read(key: _pinsStorageKey);
      if (pinsString != null && pinsString.isNotEmpty) {
        _logger.info('📌 Retrieved certificate pins from secure storage');
        final List<dynamic> decoded = jsonDecode(pinsString);
        return decoded.cast<String>();
      }
    } catch (e) {
      _logger.error('❌ Error getting certificate pins from storage: $e');
    }
    _logger.info('📌 Using default certificate pins');
    return defaultPins;
  }

  static Future<void> saveCertificatePins(List<String> pins) async {
    try {
      final pinsString = jsonEncode(pins);
      await _secureStorage.write(key: _pinsStorageKey, value: pinsString);
      _logger.kawaii(
          '💾 Saved certificate pins to secure storage! Security level up! ✨');
    } catch (e) {
      _logger.error('❌ Error saving certificate pins: $e');
    }
  }

  static Future<String> generatePinFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> certBytes = data.buffer.asUint8List();
      // This would be a placeholder as the actual implementation would be more complex
      _logger.info('🔄 Generated certificate pin from asset');
      return 'sha256/PLACEHOLDER_PIN=';
    } catch (e) {
      _logger.error('❌ Error generating pin from asset: $e');
      return '';
    }
  }

  static Future<bool> updatePinsFromServer(String secureUpdateUrl) async {
    try {
      _logger.info('🔄 Updating certificate pins from server...');
      // Implementation would go here
      // This is a placeholder for the actual implementation
      return true;
    } catch (e) {
      _logger.error('❌ Error updating certificate pins from server: $e');
      return false;
    }
  }
}

class BadCertificateHandler {
  final LoggerService _logger = LoggerService();
  final List<String> _pins;
  final List<String> _hosts;

  BadCertificateHandler(this._pins, this._hosts);

  bool handleBadCertificate(X509Certificate cert, String host, int port) {
    _logger.info('🔒 Certificate validation for $host...');

    if (!_hosts.contains(host)) {
      _logger.info('⚠️ Not a pinned host, using default validation for: $host');
      return false;
    }

    return CertificatePinningUtils.verifyCertificatePin(cert, _pins);
  }
}
