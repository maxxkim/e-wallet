import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/bloc/search/global_search_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/filter_button_row.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_history_panel.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/widget/global_search_widget.dart';
import 'widgets/dashboard_display.dart';

class DashboardScreen extends StatelessWidget with FadeInAnimationMixin {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Create GlobalSearchCubit lazily so it's only created when needed
    return BlocProvider(
      create: (context) => GlobalSearchCubit(
          RepositoryProvider.of<GlobalSearchRepository>(context)),
      lazy: false, // Create immediately to ensure it's ready
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardStateLoggedOut) {}
          if (state is DashboardStateLoaded) {
            return Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 16.0,
                  top: 49.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: staggeredFadeIn([
                    fadeInFromTop(
                      GlobalSearchWidget(
                        hintText: l10n.historySearchHint,
                        fullWidth: true,
                        autofocus: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    fadeInFromTop(
                      BalanceDisplay(
                        balance: state.balance,
                        translations: DashboardTranslations(
                          totalBalance: l10n.refresh,
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
                                    translations:
                                        TransactionHistoryTranslations(
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
              bottomNavigationBar: const CustomBottomNavBar(),
            );
          } else if (state is DashboardStateError) {
            return ErrorScreen(errorMessage: state.errorMessage);
          }
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
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

    final currentMonthNumber =
        DateFormat('MMMM').parse(state.chosenMonth).month;
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
}

class MonthData {
  final int number;
  final String localizedName;
  MonthData(this.number, this.localizedName);
}

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
