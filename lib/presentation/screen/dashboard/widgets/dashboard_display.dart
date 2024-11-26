import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class DashboardDisplay extends StatelessWidget {
  final num? balance;
  const DashboardDisplay({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    num displayedBalance = balance ?? 0;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: Theme.of(context)
                        .extension<ThemeGradients>()
                        ?.deepBlueGradient
                        .colors ??
                    [],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: deepBlueColor,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, top: 16, bottom: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/dollar.svg',
                            height: 32.0,
                            width: 32.0,
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            displayedBalance.toStringAsFixed(2),
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: const Icon(Icons.exit_to_app),
                            color: Theme.of(context).scaffoldBackgroundColor,
                            onPressed: () {
                              logout(context);
                              context.go('/');
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Row(
                          children: [
                            Text(
                              "Show",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            Text(
                              "/Hide",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  child: Container(
                    height: 56.0,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/dashboard/topUp'),
                          child: Text(
                            "Top Up",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/dashboard/withdrawal'),
                          child: Text(
                            "Withdraw",
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => context.go('/dashboard/scan'),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: deepBlueColor,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_qr.svg',
                        height: 24.0,
                        width: 24.0,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Scan",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => context.go('/dashboard/transfer'),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: deepBlueColor,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_transfer.svg',
                        height: 24.0,
                        width: 24.0,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Transfer",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void logout(BuildContext context) {
    context.read<DashboardCubit>().logout();
    context.read<SessionCubit>().checkAuthentication();
  }
}
