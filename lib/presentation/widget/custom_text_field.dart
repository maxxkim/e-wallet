import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool? autofocus;
  final Widget? icon; // Иконка будет передаваться как параметр
  final TextInputType keyboardType;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.labelText,
    this.autofocus,
    this.hintText,
    this.icon, 
    this.keyboardType = TextInputType.number,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus ?? false,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Устанавливаем отступы
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0.5),
        ),
        fillColor: Colors.white, // Устанавливаем цвет фона поля ввода на белый
        filled: true, // Включаем заполнение цвета
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0),
        ),
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        prefixIcon: icon, // Используем prefixIcon для размещения иконки внутри поля
      ),
      style: const TextStyle(color: Colors.black, fontSize: 14), // Уменьшение размера шрифта
      keyboardType: keyboardType,
    );
  }
}