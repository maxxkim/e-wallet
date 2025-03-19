import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionHistoryPanel extends StatelessWidget
    with FadeInAnimationMixin {
  final DashboardStateLoaded state;
  final TransactionHistoryTranslations translations;
  const TransactionHistoryPanel({
    super.key,
    required this.state,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    if (state.filteredTransactions?.isEmpty ?? true) {
      return _buildEmptyState(context);
    }

    // Determine how many items to display
    // Show up to 10 items on the dashboard instead of just 5
    final displayCount = state.filteredTransactions!.length > 10
        ? 10
        : state.filteredTransactions!.length;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onRefresh: () => context.read<DashboardCubit>().loadData(),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              // Don't limit number of items to 5 anymore
              itemCount: displayCount,
              itemBuilder: (context, index) {
                final transaction = state.filteredTransactions![index];
                return Column(
                  children: [
                    TransactionTile(
                      transaction: transaction,
                      onIconTap: () =>
                          _navigateToTransactionDetails(context, transaction),
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
          // Only show "View All" button if there are more than 10 transactions
          _buildViewAllButton(context),
        ],
      ),
    );
  }

  void _navigateToTransactionDetails(
      BuildContext context, Transaction transaction) {
    context.go(
      '/dashboard/transaction-details',
      extra: transaction,
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/dashboard/history'),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border(
            top: BorderSide(
              color: Theme.of(context).scaffoldBackgroundColor,
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: Text(
            translations.viewAll,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
          delay: const Duration(milliseconds: 150),
        );
  }

  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadData(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    translations.noTransactions,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
