import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 268,
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
                  labelText: l10n.transferMobileNumberLabel,
                  keyboardType: TextInputType.numberWithOptions(),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: amountController,
                  labelText: l10n.transferAmountLabel,
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
                    l10n.transferConfirmationText(
                        amountController.text, emailController.text),
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
                    SnackBar(
                      content: Text(l10n.transferFillFieldsError),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.transferContinueButton,
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
