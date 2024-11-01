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
import 'package:zippy/presentation/screen/top_up/top_up_screen.dart';
import 'package:dio/dio.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/session/session_state.dart'; // Импортируйте Dio

Widget _authGuard(BuildContext context, Widget child) {
  return BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is Authenticated) {
        return child;
      } else {
        Future.microtask(() async {
          await Future.delayed(const Duration(seconds: 1));
          GoRouter.of(context).go('/');
        });
        return Center(
            child: Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ))));
      }
    },
  );
}

Widget _authGuard2(BuildContext context, Widget child) {
  return BlocBuilder<SessionCubit, SessionState>(
    builder: (context, state) {
      if (state is Unauthenticated) {
        return child;
      } else {
        Future.microtask(() async {
          await Future.delayed(const Duration(seconds: 1));
          GoRouter.of(context).go('/dashboard');
        });
        return Center(
            child: Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ))));
      }
    },
  );
}

final GoRouter appRouter = GoRouter(
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
            return _authGuard(context, TopUpScreen());
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
    return const ErrorScreen(errorMessage: 'Произошла ошибка навигации');
  },
);
// Функция обработки ошибок
String _handleError(dynamic error) {
  if (error is DioException) {
    // Здесь вы можете обрабатывать различные типы DioException и возвращать соответствующие сообщения
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Ошибка подключения. Попробуйте еще раз.';
      case DioExceptionType.sendTimeout:
        return 'Время ожидания отправки истекло.';
      case DioExceptionType.receiveTimeout:
        return 'Время ожидания получения ответа истекло.';
      case DioExceptionType.badResponse:
        return 'Ошибка сервера: ${error.response?.statusCode}.';
      case DioExceptionType.cancel:
        return 'Запрос отменен.';
      case DioExceptionType.unknown:
        return 'Произошла неизвестная ошибка.';
      default:
        return 'Произошла ошибка.';
    }
  }
  return 'Произошла неизвестная ошибка.';
}
