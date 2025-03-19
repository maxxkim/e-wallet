import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/bloc/auth/pin_lock_screen.dart';

class AppLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AppLockScreen({
    Key? key,
    required this.onAuthenticated,
  }) : super(key: key);

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen>
    with SingleTickerProviderStateMixin {
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  late AnimationController _controller;
  bool _isAuthenticating = false;
  String _errorMessage = '';
  bool _showRetryPrompt = false;
  int _authAttempts = 0;
  bool _isPinEnabled = false;
  bool _isBiometricsEnabled = false;
  bool _isLoading = true;

  void _logEvent(String message) {
    LoggerService().info('🔒 LOCK SCREEN: $message');
  }

  @override
  void initState() {
    super.initState();
    _logEvent('AppLockScreen initialized');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _checkAuthSettings();
  }

  Future<void> _checkAuthSettings() async {
    _logEvent('Checking authentication settings');
    try {
      _isPinEnabled = await _biometricAuth.isPinEnabled();
      _isBiometricsEnabled = await _biometricAuth.isBiometricsEnabled();

      _logEvent(
          'PIN enabled: $_isPinEnabled, Biometrics enabled: $_isBiometricsEnabled');

      setState(() {
        _isLoading = false;
      });

      // If PIN is enabled, show the PIN lock screen
      if (_isPinEnabled) {
        _logEvent('PIN is enabled, showing PIN lock screen');
        // We don't start biometric auth if PIN is enabled
        return;
      }

      // Otherwise try biometric authentication
      if (_isBiometricsEnabled) {
        _logEvent('Biometrics enabled, attempting authentication');
        Future.delayed(const Duration(milliseconds: 500), () {
          _authenticate();
        });
      } else {
        _logEvent('No authentication method enabled, unlocking app');
        widget.onAuthenticated();
      }
    } catch (e) {
      _logEvent('Error checking authentication settings: $e');
      setState(() {
        _errorMessage = 'Failed to check authentication settings.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _logEvent('AppLockScreen disposed');
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) {
      _logEvent('Authentication already in progress, skipping');
      return;
    }

    _authAttempts++;
    _logEvent('Starting authentication attempt $_authAttempts');

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
      _showRetryPrompt = false;
    });

    try {
      final canAuthenticate = await _biometricAuth.isBiometricAvailable();
      _logEvent('Can authenticate with biometrics: $canAuthenticate');

      if (!canAuthenticate) {
        setState(() {
          _errorMessage =
              'Biometric authentication is not available on this device.';
          _isAuthenticating = false;
          _showRetryPrompt = false;
        });
        _logEvent('Biometrics not available: $_errorMessage');
        return;
      }

      _logEvent('Requesting biometric authentication');
      final authenticated = await _biometricAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to access your Zentro Wallet',
      );

      _logEvent('Authentication result: $authenticated');
      if (authenticated) {
        _logEvent(
            'Authentication successful, calling onAuthenticated callback');
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
          _showRetryPrompt = true;
        });
        _logEvent('Authentication failed: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during authentication.';
        _isAuthenticating = false;
        _showRetryPrompt = true;
      });
      _logEvent('❌ Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _logEvent('Building lock screen UI');

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // If PIN is enabled, show the PIN lock screen
    if (_isPinEnabled) {
      return PinLockScreen(onAuthenticated: widget.onAuthenticated);
    }

    // Otherwise show biometric authentication screen
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Theme.of(context).colorScheme.primary,
        colorScheme: Theme.of(context).colorScheme,
      ),
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withAlpha(204),
                Theme.of(context).colorScheme.secondary,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Zentro Logo
                      SvgPicture.asset(
                        'assets/images/zentro_logo.svg',
                        width: 200,
                      ).animate().fadeIn(duration: 600.ms).moveY(
                          begin: -20,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutQuad),
                      const SizedBox(height: 60),

                      // Fingerprint Icon
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Container(
                            height: 120,
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.2 + 0.1 * _controller.value),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.fingerprint,
                              size: 80 + (10 * _controller.value),
                              color: Colors.white,
                            ),
                          );
                        },
                      ).animate().fadeIn(duration: 800.ms, delay: 400.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 800.ms,
                          delay: 400.ms),
                      const SizedBox(height: 40),

                      // Lock Message
                      Text(
                        'Zentro Wallet is Locked',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 800.ms).moveY(
                          begin: 20, end: 0, duration: 600.ms, delay: 800.ms),
                      const SizedBox(height: 16),

                      // Authentication prompt
                      Text(
                        'Please authenticate with your fingerprint to continue (^ω^)',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),
                      const SizedBox(height: 40),

                      // Debug attempt counter
                      Text(
                        'Attempt $_authAttempts',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Error message (if any)
                      if (_errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(51),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withAlpha(76)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .shake(hz: 4, curve: Curves.easeInOut),
                      const SizedBox(height: 40),

                      // Retry button (shown after failed attempt)
                      if (_showRetryPrompt)
                        ElevatedButton.icon(
                          onPressed: _isAuthenticating ? null : _authenticate,
                          icon: const Icon(Icons.fingerprint),
                          label: Text(_isAuthenticating
                              ? 'Authenticating...'
                              : 'Try Again with Biometrics'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 24),
                            textStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .moveY(begin: 20, end: 0, duration: 600.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
