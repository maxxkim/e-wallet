import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TransactionFormDisplay extends StatelessWidget {
  const TransactionFormDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController amountController = TextEditingController();

    return Container(
      height: 320,
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
                      'assets/images/icon_coin.svg',
                      width: 8,
                      height: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "To transfer the amount of ${amountController.text} \nto the number ${emailController.text}, press continue.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
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
              onTap: () => context
                  .read<TransferCubit>()
                  .initializeTransfer({"amount": 3}),
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
