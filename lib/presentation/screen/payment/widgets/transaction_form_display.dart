import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TransactionFormDisplay extends StatefulWidget {
  const TransactionFormDisplay({Key? key}) : super(key: key);

  @override
  State<TransactionFormDisplay> createState() => _TransactionFormDisplayState();
}

class _TransactionFormDisplayState extends State<TransactionFormDisplay> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String? phoneError;
  String? amountError;
  bool isProcessing = false;

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    bool isValid = true;

    if (phoneController.text.isEmpty) {
      setState(() {
        phoneError = 'Phone number is required';
      });
      isValid = false;
    } else if (!_isValidPhone(phoneController.text)) {
      setState(() {
        phoneError = 'Invalid phone number format';
      });
      isValid = false;
    }

    if (amountController.text.isEmpty) {
      setState(() {
        amountError = 'Amount is required';
      });
      isValid = false;
    } else {
      final amount = double.tryParse(amountController.text);
      if (amount == null || amount <= 0) {
        setState(() {
          amountError = 'Please enter a valid amount';
        });
        isValid = false;
      }
    }

    return isValid;
  }

  bool _isValidPhone(String phone) {
    // Basic phone validation - can be made more sophisticated
    return phone.length >= 10 && phone.length <= 15;
  }

  void _handleSubmit() async {
    setState(() {
      phoneError = null;
      amountError = null;
    });

    if (!_validateFields()) return;

    setState(() {
      isProcessing = true;
    });

    try {
      await context.read<TransferCubit>().initializeTransfer({
        "recipient": phoneController.text,
        "amount": double.parse(amountController.text),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transfer failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<TransferCubit, TransferState>(
      listener: (context, state) {
        if (state is TransferStateError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          height: 343,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: phoneController,
                      labelText: l10n.transferRecipientLabel,
                      keyboardType: TextInputType.phone,
                      errorText: phoneError,
                      enabled: !isProcessing,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: amountController,
                      labelText: l10n.transferAmountLabel,
                      keyboardType: TextInputType.number,
                      errorText: amountError,
                      enabled: !isProcessing,
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
                        l10n.transferConfirmMessage(
                          amountController.text,
                          phoneController.text,
                        ),
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
                child: MaterialButton(
                  onPressed: isProcessing ? null : _handleSubmit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isProcessing)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Text(
                          l10n.continueButton,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
