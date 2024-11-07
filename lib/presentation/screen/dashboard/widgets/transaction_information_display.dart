// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionsInfoDisplay extends StatelessWidget {
  TransactionsInfoDisplay({super.key, required this.transactions});
  List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    // Получаем текущий месяц
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
    int startIndex = (currentIndex - 2)
        .clamp(0, months.length); // Начинаем с 2 месяцев до текущего
    int endIndex =
        (startIndex + 5).clamp(0, months.length); // Отображаем 5 месяцев

    return Expanded(
      // Оборачиваем в Expanded
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border.all(
                        color:
                            Theme.of(context).colorScheme.primary, // Цвет рамки
                        width: 1.0, // Толщина рамки
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: Center(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: endIndex - startIndex,
                          itemBuilder: (context, index) {
                            String month = months[startIndex + index];
                            bool isCurrentMonth = month == currentMonth;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                month,
                                style: isCurrentMonth
                                    ? Theme.of(context)
                                        .textTheme
                                        .headlineSmall // Выделяем текущий месяц
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
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: TransactionTile(
                          transaction: transactions[index],
                          onIconTap: () =>
                              context.go('/dashboard/infoDashboard'),
                        ),
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
    );
  }
}
