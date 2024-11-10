import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TopUpBalanceDisplay extends StatelessWidget {
  const TopUpBalanceDisplay({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            "Total balance",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/dollar.svg',
              height: 32.0,
              width: 32.0,
            ),
            const SizedBox(width: 16),
            Text(
              '1 800.08',
              style: Theme.of(context).textTheme.titleLarge,
            )
          ],
        ),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Select Top Up option:",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ],
    );
  }
}
