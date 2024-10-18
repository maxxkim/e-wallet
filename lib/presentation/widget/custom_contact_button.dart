import 'package:flutter/material.dart';

class ContactButton {
  final Color color; // Цвет кнопки
  final IconData? icon; // Иконка внутри кнопки (может быть null)
  final String subtitle; // Подпись под кнопкой

  ContactButton({
    required this.color,
    this.icon,
    required this.subtitle,
  });
}

