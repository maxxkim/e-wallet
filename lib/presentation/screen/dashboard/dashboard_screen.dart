import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';
import 'widgets/dashboard_display.dart';

class DashboardScreen extends StatelessWidget {
   DashboardScreen({super.key});
  final Random random = Random();
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String currentMonth = DateFormat('MMMM yy').format(now);

    final List<String> months = [
      "January 24",
      "February 24",
      "March 24",
      "April 24",
      "May 24",
      "June 24",
      "July 24",
      "August 24",
      "September 24",
      "October 24",
      "November 24",
      "December 24",
    ];

    int currentIndex = months.indexOf(currentMonth);
    int startIndex = (currentIndex - 2).clamp(0, months.length); // Начинаем с 2 месяцев до текущего
    int endIndex = (startIndex + 5).clamp(0, months.length); // Отображаем 5 месяцев




    
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: Scaffold(
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
              const DasboardDisplay(),
              const SizedBox(height: 16),

              // Button Row
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  return Row(
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
                  );
                },
              ),

              const SizedBox(height: 16),
               Expanded( // Оборачиваем в Expanded
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      BlocBuilder<DashboardCubit, DashboardState>(
                        builder: (context, state) {
                          return state.filterType == FilterType.period
                            ? Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48.0,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary, // Цвет рамки
                                  width: 1.0, // Толщина рамки
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              child:Padding(
                                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                                child: Center(
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: endIndex - startIndex,
                                    itemBuilder: (context, index) {
                                      String month = months[startIndex + index];
                                      bool isCurrentMonth = month == currentMonth;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          month,
                                          style: isCurrentMonth
                                              ? Theme.of(context).textTheme.headlineSmall // Выделяем текущий месяц
                                              : Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                        ) : const SizedBox.shrink();}),
                      Expanded(
                        child: ListView.builder(
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                TransactionTile(
                                  transaction: Transaction.generateRandomTransaction(),
                                  onIconTap: () => context.go('/dashboard/infoDashboard'),
                                ),
                                Container(height: 1, color: Theme.of(context).scaffoldBackgroundColor,),
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
      ),
    );
  }
}

