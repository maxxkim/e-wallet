import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionList extends StatelessWidget {
  const TransactionList({super.key});

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
    int startIndex = (currentIndex - 2).clamp(0, months.length); // Начинаем с 2 месяцев до текущего
    int endIndex = (startIndex + 5).clamp(0, months.length); // Отображаем 5 месяцев

    int itemCount = 77;
    return Expanded( // Оборачиваем в Expanded
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
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
            ),
            Expanded(
              child: ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      if (index < itemCount) Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.zero,
                          ),
                          child: TransactionTile(
                            id: '#123456789',
                            type: "in",
                            title: 'Transaction #${index + 1}',
                            date: 'Sep 12, 2024',
                            time: '6:30 PM',
                            currency: '\$',
                            status: 'completed',
                            amount: 1800.08,
                            onIconTap: () => context.go('/dashboard/infoDashboard'),
                        ),
                      ),
                      Container(height: 1, color: Theme.of(context).scaffoldBackgroundColor,),
                    ],
                  );
                },
              ),
            ),
              ],
            ),
        ),
    );
  }
}