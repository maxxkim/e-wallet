import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/screen/auth/auth_screen.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/screen/history/history_screen.dart';
import 'package:zippy/presentation/screen/payment/payment_info_screen.dart';
import 'package:zippy/presentation/screen/payment/payment_screen.dart';
import 'package:zippy/presentation/screen/top_up/top_up_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return AuthScreen();
      },
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
            Transaction transaction = state.extra as Transaction;
            return PaymentInfoScreen(transaction: transaction);
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
                Transaction transaction = state.extra as Transaction;
                return PaymentInfoScreen(transaction: transaction);
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
                  Transaction transaction = state.extra as Transaction;
                  return PaymentInfoScreen(transaction: transaction);
                },
            ),
          ],
        )
      ],
    ),
  ],
);