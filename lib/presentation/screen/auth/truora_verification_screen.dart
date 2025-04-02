import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:truora_sdk/truora_sdk.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class TruoraVerificationScreen extends StatefulWidget {
  final String userId;
  final String phoneNumber;

  const TruoraVerificationScreen({
    Key? key,
    required this.userId,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<TruoraVerificationScreen> createState() =>
      _TruoraVerificationScreenState();
}

class _TruoraVerificationScreenState extends State<TruoraVerificationScreen> {
  bool _isLoading = false;
  bool _isVerificationComplete = false;
  String? _errorMessage;
  TruoraSDK? _truoraSDK;
  final SecureStorageService _secureStorage = SecureStorageService();

  // This would be your actual Truora token
  static const String _token = 'YOUR_TRUORA_TOKEN';

  void _logEvent(String message) {
    LoggerService().info('🧪 TRUORA VERIFICATION: $message');
  }

  @override
  void initState() {
    super.initState();
    _logEvent('Screen initialized for user ${widget.userId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identity Verification'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              Icon(
                Icons.verified_user,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 24),

              Text(
                _isVerificationComplete
                    ? 'Verification Completed! (ﾉ◕ヮ◕)ﾉ*:・ﾟ✧'
                    : 'Verify Your Identity',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                _isVerificationComplete
                    ? 'Thank you for verifying your identity! You can now access your Zentro Wallet.'
                    : 'For your security and to comply with regulations, we need to verify your identity before you can use Zentro Wallet features! Nyaa~',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),

              if (!_isVerificationComplete)
                RectangularButton(
                  label: _isLoading
                      ? 'Starting Verification...'
                      : 'Start Verification Process',
                  onPressed: _isLoading ? null : _startVerification,
                ),

              const SizedBox(height: 16),

              // Skip button for development (remove in production)
              TextButton(
                onPressed: _isLoading ? null : _skipVerification,
                child: Text(
                  'Skip Verification (dev only)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              // This is where we put the TruoraSDK widget when verification starts
              if (_truoraSDK != null) _truoraSDK!,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startVerification() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _logEvent('Starting Truora verification flow for ${widget.phoneNumber}');

      // Create the TruoraSDK widget
      final truoraSDK = TruoraSDK(
        token: _token,
        requiredPermissions: const [
          TruoraPermission.camera,
          TruoraPermission.location,
        ],
        onError: (String errorMessage) {
          _logEvent('❌ Truora error: $errorMessage');
          setState(() {
            _isLoading = false;
            _errorMessage = 'Verification error: $errorMessage';
            _truoraSDK = null; // Remove widget when error occurs
          });
        },
        onStepsCompleted: (String status) {
          _logEvent('Steps completed: $status');
        },
        onProcessSucceeded: (String verificationId) {
          _logEvent('✅ Verification succeeded: $verificationId');
          _handleSuccessfulVerification(verificationId);
        },
        onProcessFailed: (String error) {
          _logEvent('❌ Verification failed: $error');
          setState(() {
            _isLoading = false;
            _errorMessage = error;
            _truoraSDK = null; // Remove widget when process fails
          });
        },
      );

      // Update the state to show the TruoraSDK widget
      setState(() {
        _truoraSDK = truoraSDK;
      });
    } catch (e) {
      _logEvent('❌ Error during verification process: $e');
      setState(() {
        _isLoading = false;
        _errorMessage =
            'An error occurred during verification. Please try again!';
      });
    }
  }

  void _handleSuccessfulVerification(String verificationId) async {
    _logEvent('Handling successful verification: $verificationId');

    // Save verification ID for later reference
    await _secureStorage.write(
        key: 'truora_verification_id', value: verificationId);

    if (mounted) {
      setState(() {
        _isVerificationComplete = true;
        _isLoading = false;
        _truoraSDK = null; // Remove widget when verification complete
      });

      // After successful verification, proceed to dashboard
      _proceedToApp();
    }
  }

  void _proceedToApp() async {
    _logEvent('Proceeding to dashboard after successful verification UwU');
    await context.read<SessionCubit>().checkAuthentication();
    if (mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _skipVerification() async {
    // This is for development/testing only
    _logEvent('⚠️ Skipping verification (for development purposes only)');
    await context.read<SessionCubit>().checkAuthentication();
    if (mounted) {
      context.go('/dashboard');
    }
  }
}
