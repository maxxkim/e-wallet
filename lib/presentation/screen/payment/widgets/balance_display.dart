import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BalanceDisplay extends StatelessWidget {
  final double amount;

  const BalanceDisplay({
    Key? key,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 16, bottom: 16, right:16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total balance", style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/images/dollar.svg',
                      height: 32.0,
                      width: 32.0,
                    ),
                    const SizedBox(width: 12.0),
                    Text(
                      '1 800.08',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            height: 24.0,
            width: double.infinity, // Устанавливаем ширину равной родительскому контейнеру
            decoration: BoxDecoration(  
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row( // Используем Row для выравнивания текста и иконки
              mainAxisAlignment: MainAxisAlignment.center, // Центрируем содержимое
              children: [
                Text(
                  "Select from contacts",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(width: 8), // Отступ между текстом и иконкой
                const Icon(
                  Icons.person, // Замените на нужную иконку
                  color: Colors.white, // Выберите цвет иконки
                  size: 24.0, // Размер иконки
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}