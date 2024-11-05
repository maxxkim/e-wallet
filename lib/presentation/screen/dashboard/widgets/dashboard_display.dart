import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class DashboardDisplay extends StatelessWidget {
  final int? balance;
  const DashboardDisplay({super.key, this.balance});

  @override
  Widget build(BuildContext context) {
    int displayedBalance = balance ?? 0;
    return Row(
      children: [
        // Левый контейнер с балансом
        Expanded(
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
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
                      Text("Total balance",
                          style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/dollar.svg',
                            height: 32.0,
                            width: 32.0,
                          ),
                          const SizedBox(width: 12.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayedBalance.toStringAsFixed(2),
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Row(
                                children: [
                                  Text("Show",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall),
                                  Text("/Hide",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Align(
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Top Up",
                            style: Theme.of(context).textTheme.displayMedium),
                        Text("Withdraw",
                            style: Theme.of(context).textTheme.displayMedium),
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
          padding: const EdgeInsets.only(left: 12, right: 4),
          child: Column(
            children: [
              // Правый верхний квадратный контейнер
              GestureDetector(
                onTap: () {
                  /*    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const BarcodeScannerSimple(),
                      ),
                    );*/
                },
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_scan.svg',
                        height: 24.0,
                        width: 24.0,
                      ),
                      const SizedBox(height: 4),
                      Text("Scan",
                          style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.go('/dashboard/payment'),
                child: Container(
                  height: 72,
                  width: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
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
                      Text("Transfer",
                          style: Theme.of(context).textTheme.bodyMedium),
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
}
