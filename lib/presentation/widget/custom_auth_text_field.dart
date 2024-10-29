import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final TextEditingController controller;

  const AuthTextField({
    Key? key,
    this.label = 'Mobile number',
    required this.switchValue,
    required this.onSwitchChanged,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row для лейбла и переключателя
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    onSwitchChanged(!switchValue), // Переключение при нажатии
                child: Container(
                  width: 57,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: switchValue
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                    border: Border.all(
                      color: switchValue
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
                    ), // Контур того же цвета, что и фон
                  ),
                  alignment: switchValue
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Stack(
                    children: [
                      Positioned(
                        left: switchValue ? 0 : 25, // Позиция для кнопки
                        child: CircleAvatar(
                          backgroundColor: Colors.white, // Цвет кружка
                          radius: 15, // Размер кружка
                          child: SvgPicture.asset(
                              height: 24,
                              switchValue
                                  ? 'assets/images/icon_theme_light.svg'
                                  : "assets/images/icon_theme_dark.svg",
                              semanticsLabel: 'Acme Logo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
              height:
                  8), // Отступ между лейблом+переключателем и текстовым полем
          SizedBox(
            height:
                72.0, // Установите нужную высоту (например, 72.0, что в 1.5 раза больше стандартной высоты)
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(16.0), // Закругление углов
                  borderSide:
                      const BorderSide(color: Colors.grey), // Цвет границы
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                      16.0), // Закругление углов при фокусе
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary), // Цвет границы при фокусе
                ),
                hintText: "+ 66 (119) 345 97 90",
                hintStyle: Theme.of(context).textTheme.labelMedium,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 16.0), // Отступы сверху/снизу и слева/справа
              ),
              keyboardType:
                  TextInputType.phone, // Тип клавиатуры для ввода номера
            ),
          ),
        ],
      ),
    );
  }
}
