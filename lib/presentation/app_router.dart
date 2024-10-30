import 'package:flutter/material.dart';
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
import 'package:dio/dio.dart'; // Импортируйте Dio

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return AuthScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'sms/:phoneNumber', // Параметр phoneNumber в пути
          builder: (context, state) {
            try {
              // Извлечение phoneNumber из pathParameters
              final String phoneNumber = state.pathParameters['phoneNumber']!;
              return SmsVerificationScreen(
                  phoneNumber: phoneNumber); // Передача параметра в экран
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
        return const DashboardScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'topUp',
          builder: (BuildContext context, GoRouterState state) {
            return TopUpScreen();
          },
        ),
        GoRoute(
          path: 'infoDashboard',
          builder: (context, state) {
            try {
              Transaction transaction = state.extra as Transaction;
              return PaymentInfoScreen(transaction: transaction);
            } catch (e) {
              return ErrorScreen(errorMessage: _handleError(e));
            }
          },
        ),
        GoRoute(
          path: 'history',
          builder: (BuildContext context, GoRouterState state) {
            return const HistoryScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'infoHistory',
              builder: (context, state) {
                try {
                  Transaction transaction = state.extra as Transaction;
                  return PaymentInfoScreen(transaction: transaction);
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
            return PaymentScreen();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'info',
              builder: (context, state) {
                try {
                  Transaction transaction = state.extra as Transaction;
                  return PaymentInfoScreen(transaction: transaction);
                } catch (e) {
                  return ErrorScreen(errorMessage: _handleError(e));
                }
              },
            ),
          ],
        )
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
