import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TransactionFormDisplay extends StatelessWidget {
  const TransactionFormDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                    controller: emailController,
                    labelText: 'Mobile number or Email'),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: amountController,
                  labelText: 'Amount',
                  icon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/images/icon_coins.svg',
                      width: 8,
                      height: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Равномерное распределение пространства между текстом и кнопкой
              children: [
                Expanded(
                  // Используем Expanded для того, чтобы текст занимал доступное пространство
                  child: Text(
                    "To transfer the amount of (amount)\nto the number (number), press continue.",
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 6, // Ограничиваем количество строк
                    overflow: TextOverflow
                        .ellipsis, // Добавляем многоточие, если текст слишком длинный
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => context.go('/dashboard'),
                  child: Text(
                    "Continue",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
