import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_list.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarHeight: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    hintText: "Search",
                    controller: TextEditingController(),
                  ),
                  const SizedBox(height: 16),
                  _buildHeader(context, state),
                  const SizedBox(height: 8),
                  _buildStatistics(context, state),
                  const SizedBox(height: 16),
                  _buildTransactionHeader(context),
                  const SizedBox(height: 8),
                  _buildFilterButtons(context, state),
                  const SizedBox(height: 16),
                  TransactionList(
                    transactions: state.filteredTransactions ?? [],
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

  Widget _buildHeader(BuildContext context, DashboardStateLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(state.chosenMonth, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 8),
        Text("Total: \$ ${state.balance.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  Widget _buildStatistics(BuildContext context, DashboardStateLoaded state) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Expense'),
                Text('\$ ${_calculateExpense(state).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryFixed,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Income'),
                Text('\$ ${_calculateIncome(state).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Text("Transaction history",
            style: Theme.of(context).textTheme.titleSmall));
  }

  Widget _buildFilterButtons(BuildContext context, DashboardStateLoaded state) {
    return Row(
      children: [
        _buildFilterButton(
          context,
          "Period",
          FilterType.period,
          state.filterType == FilterType.period,
        ),
        const Spacer(),
        _buildFilterButton(
          context,
          "Deposit",
          FilterType.deposit,
          state.filterType == FilterType.deposit,
        ),
        const Spacer(),
        _buildFilterButton(
          context,
          "Withdrawal",
          FilterType.withdrawal,
          state.filterType == FilterType.withdrawal,
        ),
      ],
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
        );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    FilterType type,
    bool isSelected,
  ) {
    return FilledButton(
      onPressed: () => context.read<DashboardCubit>().selectFilter(type),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24.0)),
        backgroundColor: WidgetStateProperty.all(
          isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondaryContainer,
        ),
      ),
      child: Text(
        label,
        style: isSelected
            ? Theme.of(context).textTheme.displaySmall
            : Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  double _calculateExpense(DashboardStateLoaded state) {
    return state.filteredTransactions
            ?.where((t) => t.type == 'payout')
            .fold(0.0, (sum, t) => sum! + t.amount) ??
        0.0;
  }

  double _calculateIncome(DashboardStateLoaded state) {
    return state.filteredTransactions
            ?.where((t) => t.type == 'payin')
            .fold(0.0, (sum, t) => sum! + t.amount) ??
        0.0;
  }
}
