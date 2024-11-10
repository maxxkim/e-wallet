import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/screen/auth/auth_screen.dart';
import 'package:zippy/presentation/screen/auth/sms_verification_screen.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/screen/history/history_screen.dart';
import 'package:zippy/presentation/screen/payment/payment_info_screen.dart';
import 'package:zippy/presentation/screen/payment/payment_screen.dart';
import 'package:zippy/presentation/screen/topUp/top_up_screen.dart';
import 'package:dio/dio.dart';
import 'package:zippy/presentation/screen/withdrawal/withdrawal_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/session/session_state.dart';

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

Widget _authGuard(BuildContext context, Widget child) {
  return BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is InitialLoading || state is RefreshingTokens) {
        return _loadingScreen();
      }

      if (state is Authenticated) {
        return child;
      }

      if (state is Unauthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/');
        });
        return _loadingScreen();
      }

      return _loadingScreen();
    },
  );
}

Widget _authGuard2(BuildContext context, Widget child) {
  return BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is InitialLoading || state is RefreshingTokens) {
        return _loadingScreen();
      }

      if (state is Unauthenticated) {
        return child;
      }

      if (state is Authenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go('/dashboard');
        });
        return _loadingScreen();
      }

      return _loadingScreen();
    },
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
          path: 'sms/:phoneNumber',
          builder: (context, state) {
            try {
              final String phoneNumber = state.pathParameters['phoneNumber']!;
              return _authGuard2(
                  context, SmsVerificationScreen(phoneNumber: phoneNumber));
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
          path: 'infoDashboard',
          builder: (context, state) {
            try {
              Transaction transaction = state.extra as Transaction;
              return _authGuard(
                  context, PaymentInfoScreen(transaction: transaction));
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
          routes: <RouteBase>[
            GoRoute(
              path: 'infoHistory',
              builder: (context, state) {
                try {
                  Transaction transaction = state.extra as Transaction;
                  return _authGuard(
                      context, PaymentInfoScreen(transaction: transaction));
                } catch (e) {
                  return ErrorScreen(errorMessage: _handleError(e));
                }
              },
            ),
          ],
        ),
        GoRoute(
          path: 'payment',
          builder: (BuildContext context, GoRouterState state) {
            return _authGuard(context, PaymentScreen());
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'info',
              builder: (context, state) {
                try {
                  Transaction transaction = state.extra as Transaction;
                  return _authGuard(
                      context, PaymentInfoScreen(transaction: transaction));
                } catch (e) {
                  return ErrorScreen(errorMessage: _handleError(e));
                }
              },
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) {
    return const ErrorScreen(errorMessage: 'Navigation error occurred');
  },
);

String _handleError(dynamic error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection error. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout exceeded.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout exceeded.';
      case DioExceptionType.badResponse:
        return 'Server error: ${error.response?.statusCode}.';
      case DioExceptionType.cancel:
        return 'Request canceled.';
      case DioExceptionType.unknown:
        return 'Unknown error occurred.';
      default:
        return 'An error occurred.';
    }
  }
  return 'Unknown error occurred.';
}
