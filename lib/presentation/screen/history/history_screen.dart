import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                  _buildSearchField(l10n),
                  const SizedBox(height: 16),
                  _buildHeader(context, state, l10n),
                  const SizedBox(height: 8),
                  _buildStatistics(context, state, l10n),
                  const SizedBox(height: 16),
                  _buildTransactionHeader(context, l10n),
                  const SizedBox(height: 8),
                  _buildFilterButtons(context, state, l10n),
                  const SizedBox(height: 16),
                  TransactionList(
                    transactions: state.filteredTransactions ?? [],
                    translations: TransactionListTranslations(
                      noTransactions: l10n.historyNoTransactions,
                    ),
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

  Widget _buildSearchField(AppLocalizations l10n) {
    return CustomTextField(
      hintText: l10n.historySearchHint,
      controller: _searchController,
      icon: const Padding(
        padding: EdgeInsets.all(12.0),
        child: Icon(Icons.search),
      ),
    ).animate().fadeIn(
          duration: const Duration(milliseconds: 300),
        );
  }

  Widget _buildHeader(
      BuildContext context, DashboardStateLoaded state, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(getMonthName(state.selectedMonthNumber, l10n),
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(width: 8),
        Text("${l10n.historyTotal}: \$ ${state.balance.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }

  String getMonthName(int monthNumber, AppLocalizations l10n) {
    switch (monthNumber) {
      case 1:
        return l10n.monthJanuary;
      case 2:
        return l10n.monthFebruary;
      case 3:
        return l10n.monthMarch;
      case 4:
        return l10n.monthApril;
      case 5:
        return l10n.monthMay;
      case 6:
        return l10n.monthJune;
      case 7:
        return l10n.monthJuly;
      case 8:
        return l10n.monthAugust;
      case 9:
        return l10n.monthSeptember;
      case 10:
        return l10n.monthOctober;
      case 11:
        return l10n.monthNovember;
      case 12:
        return l10n.monthDecember;
      default:
        return l10n.monthJanuary;
    }
  }

  Widget _buildStatistics(
      BuildContext context, DashboardStateLoaded state, AppLocalizations l10n) {
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
                Text(l10n.historyExpense),
                Text('\$ ${_calculateExpense(state).toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .outText
                        ?.copyWith(fontSize: 20)),
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
                Text(l10n.historyIncome),
                Text('\$ ${_calculateIncome(state).toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .inText
                        ?.copyWith(fontSize: 20)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHeader(BuildContext context, AppLocalizations l10n) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(l10n.dashboardTransactionHistory,
          style: Theme.of(context).textTheme.titleSmall),
    );
  }

  Widget _buildFilterButtons(
      BuildContext context, DashboardStateLoaded state, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFilterButton(
          context,
          l10n.dashboardPeriod,
          FilterType.period,
          state.filterType == FilterType.period,
        ),
        _buildFilterButton(
          context,
          l10n.dashboardDeposit,
          FilterType.deposit,
          state.filterType == FilterType.deposit,
        ),
        _buildFilterButton(
          context,
          l10n.dashboardWithdrawal,
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
    const double buttonHeight = 40.0;
    const double buttonWidth = 114.0;
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context)
                    .extension<ThemeGradients>()
                    ?.darkBlueGradient,
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: FilledButton(
                onPressed: () =>
                    context.read<DashboardCubit>().selectFilter(type),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            )
          : OutlinedButton(
              style: ButtonStyle(
                side: WidgetStateProperty.all(
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

class TransactionListTranslations {
  final String noTransactions;

  TransactionListTranslations({
    required this.noTransactions,
  });
}
