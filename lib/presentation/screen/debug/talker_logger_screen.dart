import 'package:flutter/material.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:zippy/internal/services/logger_service.dart';

class TalkerLoggerScreen extends StatelessWidget {
  const TalkerLoggerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final talker = LoggerService().talker;

    return TalkerScreen(
      talker: talker,
      appBarTitle: 'Zentro Wallet Logs ✨',
    );
  }
}
