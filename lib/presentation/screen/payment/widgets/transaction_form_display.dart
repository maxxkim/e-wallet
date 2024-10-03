import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TransactionFormDisplay extends StatelessWidget {

  const TransactionFormDisplay({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController amountController = TextEditingController();
    return Container(
      height: 212,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
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
                const SizedBox(height: 8),
                CustomTextField(controller: emailController, labelText: 'Mobile number or Email'),
                const SizedBox(height: 16),
                CustomTextField(controller: amountController, labelText: 'Amount', icon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset('assets/images/icon_coins.svg', width: 8, height: 8,),
                ),),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Row( // Используем Row для выравнивания текста и иконки
            mainAxisAlignment: MainAxisAlignment.center, // Центрируем содержимое
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "To transfer the amount of (amount)\nto the number (number), press continue.",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width:8),
                      FilledButton(
                        onPressed: () => print("hui"),
                        child: Text(
                          "Continue",
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}