import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:zippy/internal/services/logger_service.dart';

/// Custom Talker observer that sends logs to a remote API endpoint
class TalkerApiObserver implements TalkerObserver {
  final String apiKey = 'TV99UCUiCfmayqRqPVXnTxPpmuqKxrT3';
  final String apiEndpoint =
      'https://merchant-service-gp4xz.ondigitalocean.app/api/v1/mob-app/log';
  final Dio _dio = Dio();

  @override
  void onError(TalkerError error) {
    _sendLog('ERROR: ${error.error}\n${error.stackTrace}');
  }

  @override
  void onException(TalkerException exception) {
    _sendLog('EXCEPTION: ${exception.exception}\n${exception.stackTrace}');
  }

  @override
  void onLog(TalkerDataInterface log) {
    // Only send logs with level higher than debug to avoid flooding the API`
    _sendLog('${log.message}');
  }

  Future<void> _sendLog(String logMessage) async {
    try {
      await _dio.post(
        apiEndpoint,
        data: {'log': logMessage},
        options: Options(
          headers: {'Authorization': 'ApiKey $apiKey'},
          contentType: 'application/json',
        ),
      );
    } catch (e) {
      // Using print instead of logger to avoid infinite recursion
      print('❌ Failed to send log to API: $e');
    }
  }
}
