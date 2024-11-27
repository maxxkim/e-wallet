import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
                    BalanceDisplay(balance: state.balance),
                  ),
                  const SizedBox(height: 16),
                  fadeIn(
                    FilterButtonRow(state: state),
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
                                TransactionHistoryPanel(state: state),
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

  void navigateToScanner(BuildContext context) {
    context.go('/dashboard/scan');
  }

  Widget _buildMonthSelector(BuildContext context, DashboardStateLoaded state) {
    final List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];

    final currentMonth = state.chosenMonth;
    final currentIndex = months.indexOf(currentMonth);
    final startIndex = (currentIndex - 2).clamp(0, months.length - 1);
    final endIndex = (startIndex + 5).clamp(0, months.length);

    return Container(
      height: 56.0,
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
          final isSelected = month == currentMonth;

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
}
