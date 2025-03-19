import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:talker/talker.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:zippy/internal/services/logger_service.dart';

class AppBlocObserver extends BlocObserver {
  final Talker _talker = LoggerService().talker;
  final TalkerBlocObserver _talkerObserver = TalkerBlocObserver();

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _talker.info('🧩 Bloc created: ${bloc.runtimeType}');
    _talkerObserver.onCreate(bloc);
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _talker.debug('📨 ${bloc.runtimeType} | $event');
    _talkerObserver.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _talkerObserver.onChange(bloc, change);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _talkerObserver.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _talker.error('💢 Error in ${bloc.runtimeType}', error, stackTrace);
    super.onError(bloc, error, stackTrace);
    _talkerObserver.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _talker.info('🔒 Bloc closed: ${bloc.runtimeType}');
    _talkerObserver.onClose(bloc);
  }
}
