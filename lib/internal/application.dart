// lib/internal/application.dart
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBiometricSettings();
  }

  Future<void> _checkBiometricSettings() async {
    // Initialize biometric settings if they don't exist yet
    await _biometricAuth.getBiometricSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventBus.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // Record time when app went to background
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // Handle app resume (check if we need to lock)
      _handleAppResume();
    }
  }

  Future<void> _handleAppResume() async {
    try {
      // Get current context and settings
      final context = appNavigatorKey.currentContext;
      if (context != null) {
        // Check if we need to lock based on time elapsed
        if (_pausedTime != null) {
          final shouldLock = await _biometricAuth.shouldLockApp(_pausedTime!);
          if (shouldLock) {
            final biometricsEnabled =
                await _biometricAuth.isBiometricsEnabled();
            if (biometricsEnabled) {
              setState(() {
                _isLocked = true;
              });
              return;
            }
          }
        }

        // If we didn't lock, refresh dashboard data if we're on that screen
        final currentLocation = GoRouterState.of(context).matchedLocation;
        if (currentLocation.startsWith('/dashboard')) {
          context.read<DashboardCubit>().loadData();
        }
      }
    } catch (_) {
      // Handle errors silently
    }
  }

  void _onAuthenticated() {
    setState(() {
      _isLocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show lock screen if the app is locked
    if (_isLocked) {
      return AppLockScreen(onAuthenticated: _onAuthenticated);
    }

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
            // Add BiometricSettingsCubit
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

class DashboardRefreshObserver extends NavigatorObserver {
  final BuildContext context;
  DashboardRefreshObserver(this.context);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _checkForDashboardRefresh(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _checkForDashboardRefresh(previousRoute);
    }
  }

  void _checkForDashboardRefresh(Route<dynamic> route) {
    try {
      final settings = route.settings;
      final routeName = settings.name;
      if (routeName != null && routeName.startsWith('/dashboard')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            context.read<DashboardCubit>().loadData();
          } catch (_) {
            // Handle errors silently
          }
        });
      }
    } catch (_) {
      // Handle errors silently
    }
  }
}
