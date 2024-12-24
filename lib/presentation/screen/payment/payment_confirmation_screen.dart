import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/qr/qr_payment_cubit.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class QrPaymentConfirmation extends StatelessWidget with FadeInAnimationMixin {
  final QrPaymentResponse paymentDetails;
  final TextEditingController amountController;
  final VoidCallback onCancel;
  final Function(double) onConfirm;

  QrPaymentConfirmation({
    Key? key,
    required this.paymentDetails,
    required this.onCancel,
    required this.onConfirm,
  })  : amountController = TextEditingController(
            text: paymentDetails.qrCode.amount.toStringAsFixed(2)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<QrPaymentCubit, QrPaymentState>(
      listener: (context, state) async {
        if (state is QrPaymentSuccess && state.paymentResponse != null) {
          // Launch return URL
          final returnUrl = state.paymentResponse.payment.returnUrl;
          if (returnUrl.isNotEmpty) {
            final url = Uri.parse(returnUrl);
            if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Could not launch external browser.')),
              );
            }
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment processed successfully!')),
          );
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        } else if (state is QrPaymentProcessError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment failed: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<QrPaymentCubit, QrPaymentState>(
        builder: (context, state) {
          final isProcessing =
              state is QrPaymentScanSuccess && state.isProcessing;
          final amountError =
              state is QrPaymentScanSuccess ? state.amountError : null;

          return WillPopScope(
            onWillPop: () async => !isProcessing,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: isProcessing ? null : onCancel,
                ),
                title: Text(
                  'Payment Confirmation',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: staggeredFadeIn([
                          const SizedBox(height: 24),
                          _MerchantInfoCard(merchant: paymentDetails.merchant),
                          const SizedBox(height: 24),
                          _PaymentDetailsCard(
                            qrCode: paymentDetails.qrCode,
                            amountController: amountController,
                            errorText: amountError,
                            enabled: !isProcessing,
                          ),
                          const SizedBox(height: 32),
                          _ActionButtons(
                            onConfirm: () {
                              final amount =
                                  double.tryParse(amountController.text);
                              if (amount != null) {
                                onConfirm(amount);
                              }
                            },
                            onCancel: onCancel,
                            isProcessing: isProcessing,
                          ),
                        ]),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Processing Payment...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MerchantInfoCard extends StatelessWidget {
  final QrMerchant merchant;

  const _MerchantInfoCard({
    required this.merchant,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.store,
              size: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            merchant.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (merchant.url.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              merchant.url,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentDetailsCard extends StatelessWidget {
  final QrCode qrCode;
  final TextEditingController amountController;
  final String? errorText;
  final bool enabled;

  const _PaymentDetailsCard({
    required this.qrCode,
    required this.amountController,
    this.errorText,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: amountController,
            labelText: 'Amount',
            enabled: enabled && qrCode.type != 'FIXED',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            icon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                qrCode.currency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            errorText: errorText,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Payment Type',
            value: qrCode.type,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Transaction ID',
            value: qrCode.hash.substring(0, 8),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final bool isProcessing;

  const _ActionButtons({
    required this.onConfirm,
    required this.onCancel,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RectangularButton(
          label: isProcessing ? "Processing..." : "Confirm Payment",
          onPressed: isProcessing ? null : onConfirm,
        ),
        const SizedBox(height: 16),
        RectangularButton(
          label: "Cancel",
          color: Theme.of(context).colorScheme.error,
          onPressed: isProcessing ? null : onCancel,
        ),
      ],
    );
  }
}
