import 'package:flutter/material.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';

class ContactButtonRow extends StatelessWidget {
  final List<ContactButton> buttons;

  const ContactButtonRow({Key? key, required this.buttons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        height: 88,
        child: Row(
          mainAxisAlignment: MainAxisAlignment
              .spaceEvenly, // Центрируем элементы с равномерным пространством
          children: buttons.map((button) {
            return SizedBox(
              height: 88, // Устанавливаем высоту равной общей высоте
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius:
                        24, // Увеличиваем радиус, чтобы иконка не была слишком маленькой
                    backgroundColor: button.color,
                    child: Icon(button.icon,
                        size: 32,
                        color: Colors
                            .white), // Увеличиваем иконку для лучшей видимости
                  ),
                  const SizedBox(height: 4), // Отступ между кнопкой и подписью
                  Flexible(
                    // Используем Flexible, чтобы текст мог занимать доступное пространство
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        button.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
