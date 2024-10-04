import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';
import 'widgets/dashboard_display.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM').format(now);

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
      "December",
    ];

    int currentIndex = months.indexOf(currentMonth);
    int startIndex = (currentIndex - 2).clamp(0, months.length); 
    int endIndex = (startIndex + 5).clamp(0, months.length); 

    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                  ),
                ),
              ],
              backgroundColor: Theme.of(context).colorScheme.primary,
              toolbarHeight: 40,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  DashboardDisplay(balance: state.balance),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () => context.read<DashboardCubit>().selectFilter(FilterType.period),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24.0)),
                          backgroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.period ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.period ? Colors.white : Colors.black,
                          ),
                          textStyle: WidgetStateProperty.all(state.filterType == FilterType.period ? Theme.of(context).textTheme.displaySmall : Theme.of(context).textTheme.bodyMedium),
                        ),

                        child: const Text("Period"),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => context.read<DashboardCubit>().selectFilter(FilterType.deposit),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24.0)),
                          backgroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.deposit ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.deposit ? Colors.white : Colors.black,
                          ),
                          textStyle: WidgetStateProperty.all(state.filterType == FilterType.deposit ? Theme.of(context).textTheme.displaySmall : Theme.of(context).textTheme.bodyMedium),
                        ),
                        child: const Text("Deposit"),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () => context.read<DashboardCubit>().selectFilter(FilterType.withdrawal),
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24.0)),
                          backgroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.withdrawal ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer,
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            state.filterType == FilterType.withdrawal ? Colors.white : Colors.black,
                          ),
                          textStyle: WidgetStateProperty.all(state.filterType == FilterType.withdrawal ? Theme.of(context).textTheme.displaySmall : Theme.of(context).textTheme.bodyMedium),
                        ),
                        child: const Text("Withdrawal"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (state.filterType == FilterType.period)
                            Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                  border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 1,
                                ),

                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: endIndex - startIndex,
                                  itemBuilder: (context, index) {
                                    String month = months[startIndex + index];
                                    bool isCurrentMonth = month == currentMonth;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Center(
                                        child: Text(
                                          month,
                                          style: isCurrentMonth
                                              ? Theme.of(context).textTheme.headlineSmall
                                              : Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: state.filteredTransactions?.length ?? 0,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    TransactionTile(
                                      transaction: state.filteredTransactions![index],
                                      onIconTap: () => context.go('/dashboard/infoDashboard'),
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
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => context.go('/dashboard/history'),
                                  child: SizedBox(
                                    height: 56,
                                    child: Center(
                                      child: Text(
                                        "View All",
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
