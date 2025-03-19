import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zippy/internal/observers/custom_talker_observer.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  late final Talker talker;

  LoggerService._internal() {
    // Initialize Talker instance with cute settings nya~! 🌸
    talker = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: kDebugMode,
        maxHistoryItems: 1000,
        useConsoleLogs: true,
      ),
      // Fix #1: Replace abstract class instantiation with a constructor
      observer: CustomTalkerObserver(), // Using constructor instead of const
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
    // Fix #2: Remove the invocation of non-function expression
    // talker(); <- This was the problem! Talker is not callable UwU
    // Instead, we should just close or handle the talker properly
    // Since there's no explicit 'close' method, we'll just leave this empty
    // or you could implement proper cleanup if needed
  }
}
