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
      theme: TalkerScreenTheme(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        textColor: Theme.of(context).colorScheme.primary,
        cardColor: Theme.of(context).colorScheme.tertiaryContainer,
      ),
    );
  }
}
