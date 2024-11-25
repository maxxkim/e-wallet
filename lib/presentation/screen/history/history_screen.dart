import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_list.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<DashboardCubit>().searchTransactions(_searchController.text);
    });
  }

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
                  _buildSearchField(),
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

  Widget _buildSearchField() {
    return CustomTextField(
      hintText: "Search by title, ID or amount",
      controller: _searchController,
      icon: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Icon(Icons.search),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
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
              color: Theme.of(context).colorScheme.tertiaryContainer,
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
              color: Theme.of(context).colorScheme.tertiaryContainer,
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
      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust alignment here
      children: [
        _buildFilterButton(
          context,
          "Period",
          FilterType.period,
          state.filterType == FilterType.period,
        ),
        _buildFilterButton(
          context,
          "Deposit",
          FilterType.deposit,
          state.filterType == FilterType.deposit,
        ),
        _buildFilterButton(
          context,
          "Withdraw",
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
    const double buttonHeight =
        40.0; // Set a consistent height for both buttons
    const double buttonWidth = 116.0; // Set a consistent width for both buttons

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context)
                    .extension<ThemeGradients>()
                    ?.darkBlueGradient,
                borderRadius:
                    BorderRadius.circular(32.0), // Adjust based on your design
              ),
              child: FilledButton(
                onPressed: () =>
                    context.read<DashboardCubit>().selectFilter(type),
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors
                      .transparent), // Ensure transparency if using gradient
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            )
          : OutlinedButton(
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              onPressed: () =>
                  context.read<DashboardCubit>().selectFilter(type),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
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
