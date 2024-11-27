import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
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

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.secondary,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      onRefresh: () => context.read<DashboardCubit>().loadData(),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  _getDisplayedItemCount(state.filteredTransactions!.length),
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
          if (state.filteredTransactions!.length > 5)
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
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions found',
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

  int _getDisplayedItemCount(int totalItems) {
    return totalItems > 5 ? 5 : totalItems;
  }
}
