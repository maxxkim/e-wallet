import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zippy/data/api/api_key_manager.dart';

class ApiInitializationErrorScreen extends StatefulWidget {
  final VoidCallback onRetry;

  const ApiInitializationErrorScreen({
    Key? key,
    required this.onRetry,
  }) : super(key: key);

  @override
  State<ApiInitializationErrorScreen> createState() =>
      _ApiInitializationErrorScreenState();
}

class _ApiInitializationErrorScreenState
    extends State<ApiInitializationErrorScreen> {
  bool _isRetrying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    const Icon(
                      Icons.cloud_off_rounded,
                      size: 80,
                      color: Colors.white,
                    ).animate().scale(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.elasticOut,
                        ),
                    const SizedBox(height: 40),
                    const Text(
                      "Connection Error",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).moveY(
                        begin: 20, end: 0, duration: 600.ms, delay: 200.ms),
                    const SizedBox(height: 16),
                    Text(
                      "Zentro Wallet couldn't establish a secure connection with our servers (>﹏<)",
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
                    const SizedBox(height: 8),
                    Text(
                      "Please check your connection and try again!",
                      style: TextStyle(
                        color: Colors.white.withAlpha(230),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _isRetrying
                          ? null
                          : () async {
                              setState(() {
                                _isRetrying = true;
                              });

                              // Create a new instance to ensure fresh initialization
                              final apiKeyManager = SecureApiKeyManager();
                              await apiKeyManager.initialize();

                              // Call the retry callback
                              widget.onRetry();

                              if (mounted) {
                                setState(() {
                                  _isRetrying = false;
                                });
                              }
                            },
                      icon: _isRetrying
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label: Text(_isRetrying ? "Connecting..." : "Try Again"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ).animate().fadeIn(duration: 600.ms, delay: 800.ms).moveY(
                        begin: 20, end: 0, duration: 600.ms, delay: 800.ms),
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
