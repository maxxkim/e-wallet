import 'package:flutter/material.dart';

class CircularButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled; // Новое поле для состояния кнопки

  const CircularButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isEnabled = true, // По умолчанию кнопка активна
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isEnabled ? onPressed : null, // Деактивируем кнопку при необходимости
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: isEnabled ? Colors.indigo[900] : Colors.grey, // Меняем цвет при деактивации
          ),
          child: Icon(icon, color: Colors.white, size: 30),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.black, fontSize: 16)),
      ],
    );
  }
}