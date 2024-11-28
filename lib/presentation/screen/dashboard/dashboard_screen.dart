import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/filter_button_row.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_history_panel.dart';
import 'widgets/dashboard_display.dart';

class DashboardScreen extends StatelessWidget with FadeInAnimationMixin {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
                top: 60.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: staggeredFadeIn([
                  fadeInFromTop(
                    BalanceDisplay(
                      balance: state.balance,
                      translations: DashboardTranslations(
                        totalBalance: l10n.dashboardTotalBalance,
                        topUp: l10n.dashboardTopUp,
                        withdraw: l10n.dashboardWithdraw,
                        scan: l10n.dashboardScan,
                        transfer: l10n.dashboardTransfer,
                        selectFromContacts: l10n.dashboardSelectFromContacts,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  fadeIn(
                    FilterButtonRow(
                      state: state,
                      translations: FilterTranslations(
                        period: l10n.dashboardPeriod,
                        deposit: l10n.dashboardDeposit,
                        withdrawal: l10n.dashboardWithdrawal,
                      ),
                    ),
                    delay: 100,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: fadeIn(
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (state.filterType == FilterType.period)
                              fadeIn(
                                _buildMonthSelector(context, state),
                                delay: 200,
                              ),
                            Expanded(
                              child: fadeIn(
                                TransactionHistoryPanel(
                                  state: state,
                                  translations: TransactionHistoryTranslations(
                                    noTransactions:
                                        l10n.dashboardNoTransactions,
                                    viewAll: l10n.dashboardViewAll,
                                  ),
                                ),
                                delay: 300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      delay: 150,
                    ),
                  ),
                ]),
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

    final currentMonth = state.chosenMonth;
    final currentMonthData = months.firstWhere(
      (m) => m.localizedName == currentMonth,
      orElse: () => months[DateTime.now().month - 1],
    );
    final currentIndex = months.indexOf(currentMonthData);
    final startIndex = (currentIndex - 2).clamp(0, months.length - 1);
    final endIndex = (startIndex + 5).clamp(0, months.length);

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
        itemCount: endIndex - startIndex,
        itemBuilder: (context, index) {
          final month = months[startIndex + index];
          final isSelected = month.localizedName == currentMonth;
          return GestureDetector(
            onTap: () =>
                context.read<DashboardCubit>().selectMonth(month.localizedName),
            child: Container(
              width: 112.0,
              alignment: Alignment.center,
              child: Text(
                month.localizedName,
                style: isSelected
                    ? Theme.of(context).textTheme.headlineSmall
                    : Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Add these classes to handle translations for widgets
class DashboardTranslations {
  final String totalBalance;
  final String topUp;
  final String withdraw;
  final String scan;
  final String transfer;
  final String selectFromContacts;

  DashboardTranslations({
    required this.totalBalance,
    required this.topUp,
    required this.withdraw,
    required this.scan,
    required this.transfer,
    required this.selectFromContacts,
  });
}

class FilterTranslations {
  final String period;
  final String deposit;
  final String withdrawal;

  FilterTranslations({
    required this.period,
    required this.deposit,
    required this.withdrawal,
  });
}

class TransactionHistoryTranslations {
  final String noTransactions;
  final String viewAll;

  TransactionHistoryTranslations({
    required this.noTransactions,
    required this.viewAll,
  });
}

class MonthData {
  final int number;
  final String localizedName;

  MonthData(this.number, this.localizedName);
}
