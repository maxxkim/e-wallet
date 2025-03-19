import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zippy/internal/application.dart';
import 'package:zippy/internal/observers/bloc_observer.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger service
  final logger = LoggerService();

  // Set up global error handling
  final talker = logger.talker;

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    talker.handle(details.exception, details.stack);
  };

  // Set up Bloc observer
  Bloc.observer = AppBlocObserver();

  // Log app start
  logger.kawaii('✧*。Zentro Wallet is starting up!。*✧');

  runZonedGuarded(
    () => runApp(const ZippyApp()),
    (error, stackTrace) {
      talker.handle(error, stackTrace);
    },
  );
}
