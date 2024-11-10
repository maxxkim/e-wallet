import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionHistoryPanel extends StatelessWidget
    with FadeInAnimationMixin {
  final DashboardStateLoaded state;

  const TransactionHistoryPanel({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.filteredTransactions?.isEmpty ?? true) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount:
                _getDisplayedItemCount(state.filteredTransactions!.length),
            itemBuilder: (context, index) {
              return Column(
                children: [
                  TransactionTile(
                    transaction: state.filteredTransactions![index],
                    onIconTap: () {
                      context.go(
                        '/dashboard/history/info',
                        extra: state.filteredTransactions![index],
                      );
                    },
                  ).animate().fadeIn(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: index * 50),
                      ),
                  Container(
                    height: 1,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ],
              );
            },
          ),
        ),
        if (state.filteredTransactions!.length > 5)
          InkWell(
            onTap: () => context.go('/dashboard/history'),
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  "View All",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ),
            ),
          ).animate().fadeIn(
                duration: const Duration(milliseconds: 300),
                delay: const Duration(milliseconds: 150),
              ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  int _getDisplayedItemCount(int totalItems) {
    // Show max 5 items on dashboard, the rest will be visible in history
    return totalItems > 5 ? 5 : totalItems;
  }
}
