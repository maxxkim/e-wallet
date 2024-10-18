import 'package:flutter/material.dart';

class OutlinedButtonCustom extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OutlinedButtonCustom({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Получаем текущую тему приложения
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Закругление углов
        ),
        side: BorderSide(color: theme.colorScheme.secondary, width: 1), // Цвет границы из темы
        backgroundColor: theme.scaffoldBackgroundColor, // Прозрачный фон
      ),
      child: Text(
        label,
        style: TextStyle(
          color: theme.colorScheme.secondary, // Цвет текста из темы
          fontSize: 12,
        ),
      ),
    );
  }
}
