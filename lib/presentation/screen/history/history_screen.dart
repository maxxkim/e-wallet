// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_information_display.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_list.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DateTime? startDate;
    DateTime? endDate;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("September 2024", style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Text("Totel: \$ 4 000.00", style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16.0), // Добавьте отступы для лучшего вида
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Выровнять содержимое по левому краю
                      children: [
                        Text('Expense'),
                        Text('\$ 500', style: Theme.of(context).textTheme.titleLarge), // Замените на вычисленные расходы
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 16), // Отступ между контейнерами (при желании)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryFixed,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16.0), // Добавьте отступы для лучшего вида
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Выровнять содержимое по левому краю
                      children: [
                        Text('Income'),
                        Text('\$ 1000', style: Theme.of(context).textTheme.titleLarge), // Замените на вычисленные доходы
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align( 
              alignment: Alignment.centerLeft, 
              child: Text("Transaction history", style: Theme.of(context).textTheme.titleSmall)),
            const SizedBox(height: 16),
            const TransactionList(),
          ],
        ),
      ),
    );
  }
}