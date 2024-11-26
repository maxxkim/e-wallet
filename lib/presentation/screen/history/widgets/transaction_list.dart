import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  const TransactionList({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(context, state),
                  Expanded(
                    child: transactions.isEmpty
                        ? _buildEmptyState(context)
                        : _buildTransactionsList(context),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context, DashboardStateLoaded state) {
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
          bottom: Radius.circular(32),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = DateFormat('MMMM')
              .format(DateTime(DateTime.now().year, index + 1));
          final isSelected = month == state.chosenMonth;
          return GestureDetector(
            onTap: () => context.read<DashboardCubit>().selectMonth(month),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  month,
                  style: isSelected
                      ? Theme.of(context).textTheme.headlineSmall
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          );
        },
      ),
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
            'No transactions for this period',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            TransactionTile(
              transaction: transactions[index],
              onIconTap: () => context.go(
                '/dashboard/transaction-details',
                extra: transactions[index],
              ),
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
    );
  }
}
