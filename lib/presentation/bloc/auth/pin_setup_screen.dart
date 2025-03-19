import 'package:flutter/material.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'dart:developer' as developer;

import 'package:zippy/presentation/bloc/auth/widgets/pin_entry_widget.dart';

class PinSetupScreen extends StatefulWidget {
  final VoidCallback? onPinSetupComplete;

  const PinSetupScreen({
    Key? key,
    this.onPinSetupComplete,
  }) : super(key: key);

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  String? _firstPin;
  bool _confirmMode = false;
  bool _showError = false;
  String _errorMessage = '';
  bool _isSettingUp = false;

  void _logEvent(String message) {
    LoggerService().info('🔢 PIN SETUP SCREEN: $message');
  }

  @override
  void initState() {
    super.initState();
    _logEvent('PinSetupScreen initialized');
  }

  void _handlePinEntered(String pin) {
    if (_isSettingUp) return;

    if (!_confirmMode) {
      // First PIN entry
      setState(() {
        _firstPin = pin;
        _confirmMode = true;
        _showError = false;
      });
      _logEvent('First PIN entered, switching to confirmation mode');
    } else {
      // Confirmation PIN entry
      if (_firstPin == pin) {
        _setupPin(pin);
      } else {
        setState(() {
          _showError = true;
          _errorMessage = 'PINs do not match. Please start again.';
          _confirmMode = false;
          _firstPin = null;
        });
        _logEvent('PIN confirmation failed: PINs do not match');
      }
    }
  }

  Future<void> _setupPin(String pin) async {
    setState(() {
      _isSettingUp = true;
    });

    try {
      _logEvent('Setting up PIN');
      final success = await _biometricAuth.setPinCode(pin);

      if (success) {
        _logEvent('PIN setup successful');
        await _biometricAuth.updateBiometricSetting(pinEnabled: true);

        if (widget.onPinSetupComplete != null) {
          widget.onPinSetupComplete!();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN set successfully! (≧◡≦) ♡'),
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _showError = true;
          _errorMessage = 'Failed to set PIN. Please try again.';
          _confirmMode = false;
          _firstPin = null;
          _isSettingUp = false;
        });
        _logEvent('PIN setup failed');
      }
    } catch (e) {
      setState(() {
        _showError = true;
        _errorMessage = 'An error occurred. Please try again.';
        _confirmMode = false;
        _firstPin = null;
        _isSettingUp = false;
      });
      _logEvent('PIN setup error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withAlpha(40),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: PinEntryWidget(
                  title: _confirmMode ? 'Confirm Your PIN' : 'Create Your PIN',
                  subtitle: _confirmMode
                      ? 'Please re-enter your PIN to confirm'
                      : 'Set a 4-digit PIN to unlock your wallet',
                  onPinComplete: _handlePinEntered,
                  showError: _showError,
                  errorMessage: _errorMessage,
                  confirmMode: _confirmMode,
                  firstPin: _firstPin,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
