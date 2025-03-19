import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zippy/internal/application.dart';
import 'package:zippy/internal/observers/bloc_observer.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'dart:async';

void main() {
  // Create a top-level error handler first
  final logger = LoggerService();
  final talker = logger.talker;

  // Wrap everything in a runZonedGuarded to capture all errors
  runZonedGuarded(
    () {
      // Initialize flutter bindings INSIDE the same zone
      WidgetsFlutterBinding.ensureInitialized();

      // Set up error handlers
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        talker.handle(details.exception, details.stack);
      };

      // Initialize Bloc observer
      Bloc.observer = AppBlocObserver();

      logger.kawaii('✧*。Zentro Wallet is starting up!。*✧');

      // Run the app inside the same zone where binding was initialized
      runApp(const ZippyApp());
    },
    (error, stackTrace) {
      talker.handle(error, stackTrace);
    },
  );
}
