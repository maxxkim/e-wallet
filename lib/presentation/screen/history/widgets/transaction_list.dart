import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/history_screen.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionList extends StatelessWidget {
  final List<Transaction> transactions;
  final TransactionListTranslations translations;

  const TransactionList({
    super.key,
    required this.transactions,
    required this.translations,
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
    final l10n = AppLocalizations.of(context)!;
    final List<MonthData> months = [
      MonthData(1, l10n.monthJanuary),
      MonthData(2, l10n.monthFebruary),
      MonthData(3, l10n.monthMarch),
      MonthData(4, l10n.monthApril),
      MonthData(5, l10n.monthMay),
      MonthData(6, l10n.monthJune),
      MonthData(7, l10n.monthJuly),
      MonthData(8, l10n.monthAugust),
      MonthData(9, l10n.monthSeptember),
      MonthData(10, l10n.monthOctober),
      MonthData(11, l10n.monthNovember),
      MonthData(12, l10n.monthDecember),
    ];

    // Get the current month number from state
    final currentMonthNumber = state.selectedMonthNumber;

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
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month.number == currentMonthNumber;
          return GestureDetector(
            onTap: () =>
                context.read<DashboardCubit>().selectMonth(month.localizedName),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  month.localizedName,
                  style: isSelected
                      ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )
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
            translations.noTransactions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardCubit>().loadData(),
      child: ListView.builder(
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
      ),
    );
  }
}

class MonthData {
  final int number;
  final String localizedName;
  MonthData(this.number, this.localizedName);
}
