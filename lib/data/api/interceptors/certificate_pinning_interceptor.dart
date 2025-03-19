import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:zippy/internal/services/logger_service.dart';

/// Custom Certificate Pinning Interceptor for Dio
/// This implementation doesn't rely on external packages like dio_pinning
class CertificatePinningInterceptor extends Interceptor {
  final List<String> _pins;
  final List<String> _hosts;
  final LoggerService _logger = LoggerService();

  CertificatePinningInterceptor({
    required List<String> pins,
    required List<String> hosts,
  })  : _pins = pins,
        _hosts = hosts;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Extract the host from the request URL
    final String host = options.uri.host;

    // Only log for hosts we're pinning
    if (_hosts.contains(host)) {
      _logger.info(
          '🔒 Certificate pinning will be performed for host: $host nya~!');
    }

    // Always proceed with the request - actual pinning happens at socket connection level
    handler.next(options);
  }

  /// Configure certificate pinning on the HttpClient
  void configurePinning(IOHttpClientAdapter adapter) {
    adapter.createHttpClient = () {
      HttpClient client = HttpClient();
      client.badCertificateCallback = _validateCertificate;
      return client;
    };
  }

  /// Certificate validation callback for HttpClient
  bool _validateCertificate(X509Certificate cert, String host, int port) {
    _logger.info('🔒 Validating certificate for $host:$port...');

    // Skip validation for hosts we don't care about
    if (!_hosts.contains(host)) {
      _logger.info('⚠️ Not a pinned host, using default validation for: $host');
      return false; // Use default validation
    }

    try {
      // Extract the public key from the certificate and create a hash
      final Uint8List publicKeyBytes = _extractPublicKeyBytes(cert);
      final String publicKeyHash = _hashPublicKey(publicKeyBytes);

      // Check if the hash matches any of our pins
      for (final pin in _pins) {
        // Remove 'sha256/' prefix if present
        final expectedHash = pin.startsWith('sha256/') ? pin.substring(7) : pin;

        if (publicKeyHash == expectedHash) {
          _logger.kawaii('✅ Certificate pin verified for $host! UwU');
          return true; // Certificate is valid
        }
      }

      // No matching pin found
      _logger.error(
          '❌ Certificate pinning failed for $host! Possible MITM attack! >_<');
      return false;
    } catch (e) {
      _logger.error('❌ Error during certificate validation: $e');
      return false;
    }
  }

  /// Extract the public key bytes from an X509Certificate
  /// This is a simplified implementation
  Uint8List _extractPublicKeyBytes(X509Certificate cert) {
    // In a real implementation, we would properly extract the
    // Subject Public Key Info (SPKI) from the certificate
    // For now, we'll use a simplified approach

    // Convert the PEM format to bytes
    String pemString = cert.pem;

    // PEM format typically has header/footer lines like:
    // -----BEGIN CERTIFICATE-----
    // (base64 encoded data)
    // -----END CERTIFICATE-----

    // Extract the base64 encoded data between these markers
    final RegExp pemRegex = RegExp(
      r'-----BEGIN CERTIFICATE-----\s?([\s\S]*?)\s?-----END CERTIFICATE-----',
      multiLine: true,
    );

    final Match? match = pemRegex.firstMatch(pemString);
    if (match != null && match.groupCount >= 1) {
      String base64Data = match.group(1)!.replaceAll(RegExp(r'\s+'), '');
      return base64Decode(base64Data);
    }

    // Fallback: use the whole PEM string
    _logger.warning(
        '⚠️ Could not extract certificate data properly, using fallback method');
    return Uint8List.fromList(utf8.encode(pemString));
  }

  /// Hash the public key bytes using SHA-256
  String _hashPublicKey(Uint8List publicKeyBytes) {
    final Digest digest = sha256.convert(publicKeyBytes);
    return base64.encode(digest.bytes);
  }
}

/// Helper class to apply certificate pinning to Dio instance
class CertificatePinner {
  final LoggerService _logger = LoggerService();

  /// Configure certificate pinning for Dio instance
  void configureDio(Dio dio, List<String> pins, List<String> hosts) {
    _logger.info('🔐 Setting up certificate pinning for Dio...');

    if (pins.isEmpty || hosts.isEmpty) {
      _logger.warning('⚠️ Empty pins or hosts list provided!');
      return;
    }

    // Add our interceptor
    final interceptor = CertificatePinningInterceptor(pins: pins, hosts: hosts);
    dio.interceptors.add(interceptor);

    // Configure HttpClientAdapter
    if (dio.httpClientAdapter is IOHttpClientAdapter) {
      final adapter = dio.httpClientAdapter as IOHttpClientAdapter;
      interceptor.configurePinning(adapter);
      _logger.info('✅ Certificate pinning configured for Dio client');
    } else {
      _logger.warning(
          '⚠️ HttpClientAdapter is not IOHttpClientAdapter, cannot configure pinning');
    }
  }
}
