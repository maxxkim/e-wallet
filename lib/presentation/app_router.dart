// lib/presentation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/screen/auth/auth_screen.dart';
import 'package:zippy/presentation/screen/auth/sms_verification_screen.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/screen/debug/talker_logger_screen.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/screen/history/history_screen.dart';
import 'package:zippy/presentation/screen/offer/offer_screen.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';
import 'package:zippy/presentation/screen/payment/payment_info_screen.dart';
import 'package:zippy/presentation/screen/settings/biometrics/biometrics_settings_screen.dart';
import 'package:zippy/presentation/screen/settings/settings_screen.dart';
import 'package:zippy/presentation/screen/topUp/top_up_screen.dart';
import 'package:zippy/presentation/screen/transfer/transfer_screen.dart';
import 'package:zippy/presentation/screen/withdrawal/withdrawal_screen.dart';
import 'package:zippy/presentation/screen/contacts/contacts_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/session/session_state.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:dio/dio.dart';
import 'package:zippy/presentation/widget/barcode_scanner_simple.dart';

Widget _loadingScreen() {
  return Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ),
  );
}

Widget _withDashboardProvider(BuildContext context, Widget child) {
  return BlocProvider<DashboardCubit>(
    create: (context) => DashboardCubit(
      RepositoryProvider.of<DashboardRepository>(context),
    )..loadData(),
    child: child,
  );
}

Widget _authGuard(BuildContext context, Widget child) {
  return BlocListener<SessionCubit, SessionState>(
    listener: (context, state) {
      if (state is Unauthenticated) {
        context.go('/');
      }
    },
    child: BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is InitialLoading) {
          return _loadingScreen();
        }
        if (state is Authenticated) {
          return _withDashboardProvider(context, child);
        }
        return _loadingScreen();
      },
    ),
  );
}

Widget _authGuard2(BuildContext context, Widget child) {
  return BlocListener<SessionCubit, SessionState>(
    listener: (context, state) {
      if (state is Authenticated) {
        context.go('/dashboard');
      }
    },
    child: BlocBuilder<SessionCubit, SessionState>(
      builder: (context, state) {
        if (state is InitialLoading || state is RefreshingTokens) {
          return _loadingScreen();
        }
        if (state is Unauthenticated) {
          return child;
        }
        return _loadingScreen();
      },
    ),
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return _authGuard2(context, AuthScreen());
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'sms/:phoneNumber/:countryCode',
          builder: (context, state) {
            try {
              final String phoneNumber = state.pathParameters['phoneNumber']!;
              return _authGuard2(
                context,
                SmsVerificationScreen(
                  phoneNumber: phoneNumber,
                  countryCode: state.pathParameters['countryCode'] ?? 'CL',
                ),
              );
            } catch (e) {
              return ErrorScreen(errorMessage: _handleError(e));
            }
          },
        ),
      ],
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return _authGuard(context, const DashboardScreen());
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'scan',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, const BarcodeScannerSimple());
          },
        ),
        GoRoute(
          path: 'topUp',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, const TopUpScreen());
          },
        ),
        GoRoute(
          path: 'withdrawal',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, const WithdrawalScreen());
          },
        ),
        GoRoute(
          path: 'transaction-details',
          builder: (context, state) {
            try {
              final transaction = state.extra as Transaction;
              return _authGuard(
                context,
                PaymentInfoScreen(transaction: transaction),
              );
            } catch (e) {
              return ErrorScreen(errorMessage: _handleError(e));
            }
          },
        ),
        GoRoute(
          path: 'history',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, const HistoryScreen());
          },
        ),
        GoRoute(
            path: 'transfer',
            builder: (BuildContext context, GoRouterState state) {
              return _authGuard(context, const TransferScreen());
            },
            routes: [
              GoRoute(
                path: 'contacts',
                builder: (BuildContext context, GoRouterState state) {
                  return _authGuard(context, const ContactsScreen());
                },
              ),
            ]),
        GoRoute(
          path: 'offers',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(
              context,
              BlocProvider<OfferCubit>(
                create: (context) {
                  final cubit = OfferCubit(
                    RepositoryProvider.of<OfferRepository>(context),
                  );

                  if (state.extra is MerchantData) {
                    final merchantData = state.extra as MerchantData;

                    cubit.selectMerchants([merchantData]);
                  }
                  return cubit;
                },
                lazy: false,
                child: const OfferScreen(),
              ),
            );
          },
        ),
        // Add settings routes
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, const SettingsScreen());
          },
          routes: [
            GoRoute(
              path: 'biometrics',
              builder: (BuildContext context, GoRouterState state) {
                return _authGuard(context, const BiometricSettingsScreen());
              },
            ),
          ],
        ),
        GoRoute(
          path: 'logs',
          builder: (BuildContext context, GoRouterState state) {
            LoggerService().debug('Navigating to logs screen');
            return _authGuard(context, const TalkerLoggerScreen());
          },
        ),
      ],
    ),
  ],
  redirect: (BuildContext context, GoRouterState state) {
    if (state.matchedLocation == '/dashboard' && state.extra != 'skipRefresh') {
      try {
        final dashboardCubit = context.read<DashboardCubit>();

        if (dashboardCubit.state is! DashboardStateLoaded) {
          dashboardCubit.loadData();
        }
      } catch (_) {
        // Silently handle errors
      }
    }

    return null;
  },
  errorBuilder: (BuildContext context, GoRouterState state) {
    return const ErrorScreen(errorMessage: 'Navigation error occurred');
  },
);

String _handleError(dynamic error) {
  if (error is DioException) {
    if (error.response?.data != null &&
        error.response?.data['status'] == 'error' &&
        error.response?.data['message'] != null) {
      return error.response?.data['message'];
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout occurred. Please check your internet!';
      case DioExceptionType.sendTimeout:
        return 'Send timeout exceeded. Try again!';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout exceeded. Please try again!';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        if (error.error is String) {
          return error.error as String;
        }
        return 'An unexpected error occurred. Please try again!';
      default:
        return 'An error occurred. Please try again!';
    }
  }
  return error.toString();
}
