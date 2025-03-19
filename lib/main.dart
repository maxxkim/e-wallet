import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/data/api/api_key_manager.dart';
import 'package:zippy/internal/application.dart';
import 'package:zippy/internal/observers/bloc_observer.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'dart:async';

import 'package:zippy/presentation/screen/api_error_screen.dart';

void main() {
  final logger = LoggerService();
  final talker = logger.talker;

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        talker.handle(details.exception, details.stack);
      };

      Bloc.observer = AppBlocObserver();
      logger.kawaii('✧*。Zentro Wallet is starting up!。*✧');

      // Initialize API key manager first and wait for result
      final apiKeyManager = SecureApiKeyManager();
      bool initialized = await apiKeyManager.initialize();

      if (initialized) {
        // Only start the app if API keys are properly initialized
        runApp(const ZippyApp());
      } else {
        // Show error screen if API keys couldn't be initialized
        runApp(MaterialApp(
          home: ApiInitializationErrorScreen(
            onRetry: () async {
              // Attempt to initialize again
              final apiKeyManager = SecureApiKeyManager();
              bool success = await apiKeyManager.initialize();

              if (success) {
                // If successful, start the main app
                runApp(const ZippyApp());
              }
              // If failed, the error screen will remain visible
            },
          ),
          theme: ThemeData(
            primarySwatch: Colors.indigo,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.indigo,
              brightness: Brightness.light,
            ),
          ),
        ));
      }
    },
    (error, stackTrace) {
      talker.handle(error, stackTrace);
    },
  );
}
