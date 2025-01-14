import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TransactionFormDisplay extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController amountController;

  const TransactionFormDisplay({
    Key? key,
    required this.emailController,
    required this.amountController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 252,
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
                  labelText: 'Mobile number or Email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: amountController,
                  labelText: 'Amount',
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  icon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SvgPicture.asset(
                      'assets/images/icon_coin.svg',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "To transfer the amount of ${amountController.text}\nto the number ${emailController.text}, press continue.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 48.0,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: Theme.of(context)
                  .extension<ThemeGradients>()
                  ?.darkBlueGradient,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            child: GestureDetector(
              onTap: () {
                if (emailController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  context.read<TransferCubit>().initializeTransfer({
                    "amount": double.tryParse(amountController.text) ?? 0,
                    "recipient": emailController.text,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields UwU'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
