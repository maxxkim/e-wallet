import 'package:flutter/material.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';
import 'package:zippy/presentation/bloc/auth/widgets/pin_entry_widget.dart';
import 'dart:developer' as developer;

class PinLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const PinLockScreen({
    Key? key,
    required this.onAuthenticated,
  }) : super(key: key);

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  bool _showError = false;
  int _attempts = 0;
  String? _errorMessage;
  bool _isVerifying = false;

  void _logEvent(String message) {
    developer.log(message, name: 'PinLockScreen');
    print('🔢 PIN LOCK SCREEN: $message');
  }

  @override
  void initState() {
    super.initState();
    _logEvent('PinLockScreen initialized');
  }

  Future<void> _verifyPin(String pin) async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      _logEvent('Verifying PIN');
      final isValid = await _biometricAuth.verifyPinCode(pin);

      if (isValid) {
        _logEvent('PIN verification successful');
        widget.onAuthenticated();
      } else {
        _attempts++;
        setState(() {
          _showError = true;
          _errorMessage = _attempts >= 3
              ? 'Multiple failed attempts. Please try again carefully.'
              : 'Incorrect PIN. Please try again.';
          _isVerifying = false;
        });
        _logEvent('PIN verification failed. Attempt $_attempts');
      }
    } catch (e) {
      setState(() {
        _showError = true;
        _errorMessage = 'An error occurred. Please try again.';
        _isVerifying = false;
      });
      _logEvent('PIN verification error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: PinEntryWidget(
                    title: 'Zentro Wallet is Locked',
                    subtitle: 'Enter your PIN to continue',
                    onPinComplete: _verifyPin,
                    showError: _showError,
                    errorMessage:
                        _errorMessage ?? 'Incorrect PIN. Please try again.',
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
