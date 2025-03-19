import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/data/repository/activation/activation_data_repository.dart';
import 'package:zippy/data/repository/offer/offer_data_repository.dart';
import 'package:zippy/data/repository/search/global_search_data_repository.dart';
import 'package:zippy/domain/repository/activation/activation_repository.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';
import 'package:zippy/internal/services/biometric_auth_service.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';
import 'package:zippy/l10n/l10n.dart';
import 'package:zippy/data/repository/auth/auth_data_repository.dart';
import 'package:zippy/data/repository/dashboard/dashboard_data_repository.dart';
import 'package:zippy/data/repository/qr/qr_payment_data_repository.dart';
import 'package:zippy/data/repository/transfer/transfer_data_repository.dart';
import 'package:zippy/data/repository/withdrawal/withdrawal_data_repository.dart';
import 'package:zippy/data/repository/contacts/contacts_data_repository.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';
import 'package:zippy/presentation/app_router.dart';
import 'package:zippy/presentation/bloc/biometrics/biometrics_cubit.dart';
import 'package:zippy/presentation/screen/auth/app_lock_screen.dart';
import 'package:zippy/presentation/bloc/locale/locale_cubit.dart';
import 'package:zippy/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:zippy/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/bloc/search/global_search_cubit.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/theme/app_theme_dark.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/data/repository/top_up/top_up_data_repository.dart';
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/data/api/service/api_service.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/events/transaction_events.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'dart:developer' as developer;

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class ZippyApp extends StatefulWidget {
  const ZippyApp({super.key});

  @override
  State<ZippyApp> createState() => _ZippyAppState();
}

class _ZippyAppState extends State<ZippyApp> with WidgetsBindingObserver {
  final TransactionEventBus _eventBus = TransactionEventBus();
  final BiometricAuthService _biometricAuth = BiometricAuthService();
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _isLocked = false;
  DateTime? _pausedTime;
  static const String _lastAppCloseTimeKey = 'last_app_close_time';

  @override
  void initState() {
    super.initState();
    _logEvent('⭐️ App InitState called');
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricSettings();
    _checkLockStatusOnStart();
  }

  void _logEvent(String message) {
    LoggerService().info('🔒 BIOMETRIC DEBUG: $message');
  }

  Future<void> _checkLockStatusOnStart() async {
    try {
      _logEvent('Checking lock status on app start...');

      // First check if either biometrics or PIN is enabled
      final biometricsEnabled = await _biometricAuth.isBiometricsEnabled();
      final pinEnabled = await _biometricAuth.isPinEnabled();

      _logEvent(
          'Authentication status: Biometrics enabled: $biometricsEnabled, PIN enabled: $pinEnabled');

      if (!biometricsEnabled && !pinEnabled) {
        _logEvent(
            'Neither biometrics nor PIN enabled, not locking app on start');
        return;
      }

      final lastCloseTimeStr =
          await _secureStorage.read(key: _lastAppCloseTimeKey);
      _logEvent('Last app close time from storage: $lastCloseTimeStr');

      if (lastCloseTimeStr != null) {
        final lastCloseTime = DateTime.parse(lastCloseTimeStr);
        final now = DateTime.now();
        final appClosedDuration = now.difference(lastCloseTime);
        _logEvent('App was closed for ${appClosedDuration.inSeconds} seconds');

        final biometricSettings = await _biometricAuth.getBiometricSettings();
        _logEvent('Biometric settings: enabled=${biometricSettings.enabled}, '
            'pinEnabled=${biometricSettings.pinEnabled}, '
            'timeout=${biometricSettings.lockTimeoutSeconds}s');

        final shouldLock = await _biometricAuth.shouldLockApp(lastCloseTime);
        _logEvent('Should lock app based on timeout? $shouldLock');

        if (shouldLock) {
          _logEvent('🔒 LOCKING APP on start!');
          setState(() {
            _isLocked = true;
          });
        } else {
          _logEvent('Not locking app on start (timeout not reached)');
        }
      } else {
        _logEvent('No previous app close time found in storage');
      }
    } catch (e) {
      _logEvent('❌ Error checking app lock on start: $e');
    }
  }

  Future<void> _checkBiometricSettings() async {
    try {
      final settings = await _biometricAuth.getBiometricSettings();
      _logEvent('Retrieved biometric settings: $settings');
    } catch (e) {
      _logEvent('Error retrieving biometric settings: $e');
    }
  }

  @override
  void dispose() {
    _logEvent('App Dispose called');
    WidgetsBinding.instance.removeObserver(this);
    _eventBus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logEvent('App lifecycle state changed to: $state');
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
      _logEvent('App paused at: $_pausedTime');
      _secureStorage
          .write(
        key: _lastAppCloseTimeKey,
        value: _pausedTime!.toIso8601String(),
      )
          .then((_) {
        _logEvent('Saved app pause time to secure storage');
      }).catchError((e) {
        _logEvent('❌ Error saving pause time: $e');
      });
    } else if (state == AppLifecycleState.resumed) {
      _logEvent('App resumed, calling _handleAppResume()');
      _handleAppResume();
    } else if (state == AppLifecycleState.detached) {
      _logEvent('App detached - might be terminating');
    }
  }

  Future<void> _handleAppResume() async {
    _logEvent('_handleAppResume() called');
    try {
      if (_isLocked) {
        _logEvent('App is already locked, skipping lock check');
        return;
      }

      if (_pausedTime != null) {
        final now = DateTime.now();
        final backgroundDuration = now.difference(_pausedTime!);
        _logEvent(
            'App was in background for ${backgroundDuration.inSeconds} seconds');

        final biometricsEnabled = await _biometricAuth.isBiometricsEnabled();
        final pinEnabled = await _biometricAuth.isPinEnabled();
        _logEvent(
            'Authentication status: Biometrics enabled: $biometricsEnabled, PIN enabled: $pinEnabled');

        if (!biometricsEnabled && !pinEnabled) {
          _logEvent('Neither biometrics nor PIN enabled, not locking app');
          return;
        }

        final shouldLock = await _biometricAuth.shouldLockApp(_pausedTime!);
        _logEvent('Should lock app based on time? $shouldLock');

        if (shouldLock) {
          _logEvent('🔒 LOCKING APP on resume!');
          setState(() {
            _isLocked = true;
          });
          return;
        }
      } else {
        _logEvent('No _pausedTime available, skipping lock check');
      }

      if (!_isLocked) {
        final context = appNavigatorKey.currentContext;
        if (context != null) {
          try {
            final currentLocation = GoRouterState.of(context).matchedLocation;
            _logEvent('Current location: $currentLocation');
            if (currentLocation.startsWith('/dashboard')) {
              _logEvent('On dashboard, refreshing data');

              try {
                context.read<DashboardCubit>().loadData();
              } catch (e) {
                _logEvent('Non-critical error refreshing dashboard: $e');
              }
            }
          } catch (e) {
            _logEvent('Error refreshing dashboard: $e');
          }
        } else {
          _logEvent('No valid context available for dashboard refresh');
        }
      }
    } catch (e) {
      _logEvent('❌ Error handling app resume: $e');
    }
  }

  void _onAuthenticated() {
    _logEvent('Authentication successful, unlocking app');
    setState(() {
      _isLocked = false;

      _pausedTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      _logEvent('Building UI: showing lock screen');
      return AppLockScreen(onAuthenticated: _onAuthenticated);
    }

    _logEvent('Building UI: showing main app');
    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ApiService>(
            create: (context) => ApiService(),
          ),
          RepositoryProvider<ApiUtil>(
            create: (context) => ApiUtil(
              RepositoryProvider.of<ApiService>(context),
            ),
          ),
          RepositoryProvider<TopUpRepository>(
            create: (context) => TopUpDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<DashboardRepository>(
            create: (context) => DashboardDataRepository(
                RepositoryProvider.of<ApiUtil>(context)),
          ),
          RepositoryProvider<AuthRepository>(
            create: (context) =>
                AuthDataRepository(RepositoryProvider.of<ApiUtil>(context)),
          ),
          RepositoryProvider<WithdrawalRepository>(
            create: (context) => WithdrawalDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<TransferRepository>(
            create: (context) => TransferDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<QrPaymentRepository>(
            create: (context) => QrPaymentDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<ContactsRepository>(
            create: (context) => ContactsDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<OfferRepository>(
            create: (context) => OfferDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<ActivationRepository>(
            create: (context) => ActivationDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<GlobalSearchRepository>(
            create: (context) => GlobalSearchDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => NavigationCubit()),
            BlocProvider(
              create: (context) => ThemeCubit(),
            ),
            BlocProvider(
              create: (context) =>
                  SessionCubit(RepositoryProvider.of<AuthRepository>(context)),
            ),
            BlocProvider(
              create: (context) => LocaleCubit(),
            ),
            BlocProvider(
              create: (context) => ContactsCubit(
                RepositoryProvider.of<ContactsRepository>(context),
              ),
            ),
            BlocProvider(
              create: (context) => GlobalSearchCubit(
                RepositoryProvider.of<GlobalSearchRepository>(context),
              ),
            ),
            BlocProvider(
              create: (context) => OfferCubit(
                RepositoryProvider.of<OfferRepository>(context),
              ),
            ),
            BlocProvider(
              create: (context) => DashboardCubit(
                RepositoryProvider.of<DashboardRepository>(context),
              ),
              lazy: false,
            ),
            BlocProvider(
              create: (context) => BiometricSettingsCubit(
                _biometricAuth,
              ),
            ),
          ],
          child: Builder(
            builder: (context) {
              context.read<SessionCubit>().checkAuthentication();
              return BlocBuilder<ThemeCubit, AppTheme>(
                builder: (context, theme) {
                  return BlocBuilder<LocaleCubit, Locale>(
                    builder: (context, locale) {
                      return MaterialApp.router(
                        routerConfig: appRouter,
                        title: 'Zentro Wallet',
                        locale: locale,
                        theme:
                            (theme == AppTheme.light) ? appTheme : appThemeDark,
                        localizationsDelegates: const [
                          AppLocalizations.delegate,
                          GlobalMaterialLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                        ],
                        supportedLocales: L10n.all,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
