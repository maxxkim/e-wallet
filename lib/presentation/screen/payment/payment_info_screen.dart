import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class PaymentInfoScreen extends StatelessWidget with FadeInAnimationMixin {
  final Transaction transaction;

  const PaymentInfoScreen({required this.transaction, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: fadeIn(const Text('Payment info')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: staggeredFadeIn([
            const SizedBox(height: 40),
            Center(
              child: Text(
                getText(context),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0),
              child: fadeInFromTop(
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: getContainer(context),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (transaction.type == "deposit")
                        Text(
                          'Top Up',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      if (transaction.type == "withdraw")
                        Text(
                          'Withdraw',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      const SizedBox(height: 16),
                      getIcon(context),
                      const SizedBox(height: 16),
                      Text(
                        '${getSign(context)} ${transaction.amount} ${transaction.currency}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Balance: ",
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              '${transaction.currency} 1356.32',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                            ),
                            Text(" → ",
                                style: Theme.of(context).textTheme.titleMedium),
                            Text(
                              '${transaction.currency} ${1356.32 + transaction.amount.roundToDouble()}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            fadeIn(
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context,
                      'assets/images/icon_support_lg.svg',
                      'Help',
                    ),
                    const SizedBox(width: 32),
                    _buildActionButton(
                      context,
                      'assets/images/icon_copy_lg.svg',
                      'Copy',
                    ),
                    const SizedBox(width: 32),
                    _buildActionButton(
                      context,
                      'assets/images/icon_share_lg.svg',
                      'Share',
                    ),
                  ],
                ),
              ),
              delay: 300,
            ),
            const SizedBox(
              height: 96,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 40, left: 40),
              child: fadeIn(
                RectangularButton(
                  label: "Home",
                  onPressed: () {
                    context.go('/dashboard');
                  },
                ),
                delay: 400,
              ),
            ),
            const SizedBox(height: 88),
          ]),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String iconPath, String label) {
    return Column(
      children: [
        SvgPicture.asset(
          iconPath,
          height: 40.0,
          width: 40.0,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  String getSign(BuildContext context) {
    if (transaction.type == "in") {
      return "+";
    } else {
      return "-";
    }
  }

  Color getContainer(BuildContext context) {
    if (transaction.status == "success") {
      return Theme.of(context).colorScheme.secondaryContainer;
    } else if (transaction.status == "pending") {
      return Theme.of(context).colorScheme.onTertiaryContainer;
    } else {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Widget getIcon(BuildContext context) {
    if (transaction.status == "success") {
      return SvgPicture.asset(
        'assets/images/icon_tick.svg',
        height: 48.0,
        width: 48.0,
      );
    } else if (transaction.status == "pending") {
      return SvgPicture.asset(
        'assets/images/icon_transaction_pending.svg',
        height: 48.0,
        width: 48.0,
      );
    } else {
      return SvgPicture.asset(
        'assets/images/icon_transaction_error.svg',
        height: 48.0,
        width: 48.0,
      );
    }
  }

  String getText(BuildContext context) {
    if (transaction.status == "success") {
      return "Transaction was completed\nsuccessfully!";
    } else if (transaction.status == "pending") {
      return "Transaction is being\nprocessed!";
    } else {
      return "Transaction\nwas not complete!";
    }
  }
}
