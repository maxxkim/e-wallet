// lib/presentation/screen/auth/app_lock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _authenticate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
      _showRetryPrompt = false;
    });

    try {
      final canAuthenticate = await _biometricAuth.isBiometricAvailable();
      if (!canAuthenticate) {
        setState(() {
          _errorMessage =
              'Biometric authentication is not available on this device.';
          _isAuthenticating = false;
          _showRetryPrompt = false;
        });
        return;
      }

      final authenticated = await _biometricAuth.authenticateWithBiometrics(
        localizedReason: 'Please authenticate to access your Zentro Wallet',
      );

      if (authenticated) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _errorMessage = 'Authentication failed. Please try again.';
          _isAuthenticating = false;
          _showRetryPrompt = true;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during authentication.';
        _isAuthenticating = false;
        _showRetryPrompt = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context)
                  .colorScheme
                  .primary
                  .withAlpha(204), // 0.8 opacity
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
                    // Logo with animation
                    SvgPicture.asset(
                      'assets/images/zentro_logo.svg',
                      width: 200,
                    ).animate().fadeIn(duration: 600.ms).moveY(
                        begin: -20,
                        end: 0,
                        duration: 600.ms,
                        curve: Curves.easeOutQuad),

                    const SizedBox(height: 60),

                    // Lock icon with pulsing animation
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
                        begin: Offset(0.8, 0.8),
                        end: Offset(1, 1),
                        duration: 800.ms,
                        delay: 400.ms),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      'Zentro Wallet is Locked',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).moveY(
                        begin: 20, end: 0, duration: 600.ms, delay: 800.ms),

                    const SizedBox(height: 16),

                    // Subtitle
                    Text(
                      'Please authenticate with your fingerprint to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withAlpha(230), // 0.9 opacity
                          ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 1000.ms),

                    const SizedBox(height: 40),

                    // Error message if any
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(51), // 0.2 opacity
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.red.withAlpha(76)), // 0.3 opacity
                        ),
                        child: Row(
                          children: [
                            Icon(
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

                    // Retry button if needed
                    if (_showRetryPrompt)
                      ElevatedButton.icon(
                        onPressed: _isAuthenticating ? null : _authenticate,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(_isAuthenticating
                            ? 'Authenticating...'
                            : 'Try Again with Biometrics'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
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
    );
  }
}
