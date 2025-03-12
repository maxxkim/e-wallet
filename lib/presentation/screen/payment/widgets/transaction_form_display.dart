import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class TransactionFormDisplay extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController amountController;
  const TransactionFormDisplay({
    Key? key,
    required this.emailController,
    required this.amountController,
  }) : super(key: key);

  @override
  State<TransactionFormDisplay> createState() => _TransactionFormDisplayState();
}

class _TransactionFormDisplayState extends State<TransactionFormDisplay> {
  late MaskTextInputFormatter phoneMaskFormatter;

  @override
  void initState() {
    super.initState();
    // Initialize phone mask formatter with +
    phoneMaskFormatter = MaskTextInputFormatter(
      mask: "+################################",
      filter: {"#": RegExp(r'[0-9]')},
    );

    // Pre-fill with + if empty
    if (widget.emailController.text.isEmpty) {
      widget.emailController.text = "+";
    } else if (!widget.emailController.text.startsWith('+')) {
      widget.emailController.text = "+${widget.emailController.text}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<TransferCubit, TransferState>(
      builder: (context, state) {
        final bool isLoading = state is TransferStateLoading;
        return Container(
          height: 272,
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
                    TextField(
                      controller: widget.emailController,
                      inputFormatters: [phoneMaskFormatter],
                      decoration: InputDecoration(
                        labelText: l10n.transferMobileNumberLabel,
                        hintText: "+ (123) 456 78 90",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: widget.amountController,
                      decoration: InputDecoration(
                        labelText: l10n.transferAmountLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            'assets/images/icon_coin.svg',
                            width: 8,
                            height: 8,
                          ),
                        ),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      enabled: !isLoading,
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
                            widget.amountController.text,
                            widget.emailController.text),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading
                    ? null
                    : () {
                        if (widget.emailController.text.isNotEmpty &&
                            widget.amountController.text.isNotEmpty) {
                          context.read<TransferCubit>().initializeTransfer({
                            "amount":
                                double.tryParse(widget.amountController.text) ??
                                    0,
                            "recipient": widget.emailController.text,
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
                child: Container(
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
                  child: Center(
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Processing...",
                                style: Theme.of(context).textTheme.displaySmall,
                              ),
                            ],
                          )
                        : Text(
                            l10n.transferContinueButton,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
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
