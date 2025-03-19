import 'package:talker/talker.dart';

// Create a custom concrete implementation of TalkerObserver
class CustomTalkerObserver implements TalkerObserver {
  @override
  void onError(TalkerError error) {
    // Implementation for error handling
  }

  @override
  void onException(TalkerException exception) {
    // Implementation for exception handling
  }

  @override
  void onLog(TalkerDataInterface log) {
    // Implementation for log handling
  }
}
