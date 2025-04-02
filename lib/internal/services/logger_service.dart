import 'package:talker_flutter/talker_flutter.dart';
import 'package:zippy/internal/observers/custom_talker_observer.dart';
import 'package:zippy/internal/observers/talker_api_observer.dart'; // Import our new observer

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  late final Talker talker;

  LoggerService._internal() {
    // Initialize Talker with both observers
    talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true, // Enable in all builds, not just debug
        maxHistoryItems: 1000,
        useConsoleLogs: true,
      ),
      observer: TalkerApiObserver(), // Add our new API observer
    );

    talker.info('✨ Talker initialized successfully nyaa~! UwU ✨');
  }

  void debug(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.debug('🐱 $message', exception, stackTrace);
  }

  void info(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.info('💙 $message', exception, stackTrace);
  }

  void warning(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.warning('⚠️ $message', exception, stackTrace);
  }

  void error(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.error('🙀 $message', exception, stackTrace);
  }

  void critical(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.critical('💥 $message', exception, stackTrace);
  }

  void kawaii(dynamic message, {dynamic exception, StackTrace? stackTrace}) {
    talker.info('✧･ﾟ: *✧･ﾟ:* $message *:･ﾟ✧*:･ﾟ✧', exception, stackTrace);
  }

  void handleException(dynamic exception, {StackTrace? stackTrace}) {
    talker.handle(exception, stackTrace);
  }

  void dispose() {
    // Nothing to dispose for Talker
  }
}
