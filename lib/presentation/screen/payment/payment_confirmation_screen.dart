import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/qr/product_model.dart'; // Import the new model
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
        if (state is QrPaymentSuccess) {
          context.go(
            '/dashboard/transaction-details',
            extra: state.transaction,
          );
        } else if (state is QrPaymentProcessError) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Payment failed: ${state.message}')),
            );
          }
        }
      },
      child: BlocBuilder<QrPaymentCubit, QrPaymentState>(
        builder: (context, state) {
          final isProcessing =
              state is QrPaymentScanSuccess && state.isProcessing;
          final amountError =
              state is QrPaymentScanSuccess ? state.amountError : null;

          // Calculate discount and final amounts
          final originalAmount = double.tryParse(amountController.text) ?? 0.0;
          double discountAmount = 0.0;
          double finalAmount = originalAmount;

          // Get discount from QR code directly if available
          if (paymentDetails.qrCode.discount != null &&
              paymentDetails.qrCode.discount! > 0) {
            discountAmount = paymentDetails.qrCode.discount!;
          }
          // Otherwise calculate from offer/activation if available
          else if (paymentDetails.offer != null &&
              paymentDetails.activation != null) {
            final discountValue =
                double.tryParse(paymentDetails.offer!.discount) ?? 0;
            final bonusValue =
                double.tryParse(paymentDetails.offer!.bonus) ?? 0;

            if (discountValue > 0) {
              if (paymentDetails.offer!.discountType == 'PERCENTAGE') {
                discountAmount = originalAmount * (discountValue / 100);
              } else {
                discountAmount = discountValue;
              }
            } else if (bonusValue > 0) {
              if (paymentDetails.offer!.bonusType == 'PERCENTAGE') {
                discountAmount = originalAmount * (bonusValue / 100);
              } else {
                discountAmount = bonusValue;
              }
            }
          }

          finalAmount = originalAmount - discountAmount;
          if (finalAmount < 0) finalAmount = 0;

          return PopScope(
            canPop: !isProcessing,
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
                            offer: paymentDetails.offer,
                            activation: paymentDetails.activation,
                            amountController: amountController,
                            errorText: amountError,
                            enabled: !isProcessing,
                            merchantName: paymentDetails.merchant.name,
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
                            finalAmount: finalAmount,
                            currency: paymentDetails.qrCode.currency,
                          ),
                        ]),
                      ),
                    ),
                  ),
                  if (isProcessing)
                    Container(
                      color: Colors.black.withAlpha(138),
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
              color: Theme.of(context).colorScheme.primary.withAlpha(26),
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
  final QrOffer? offer;
  final QrActivation? activation;
  final TextEditingController amountController;
  final String? errorText;
  final bool enabled;
  final String merchantName;

  const _PaymentDetailsCard({
    required this.qrCode,
    this.offer,
    this.activation,
    required this.amountController,
    this.errorText,
    required this.enabled,
    required this.merchantName,
  });

  @override
  Widget build(BuildContext context) {
    // Original amount (before discount)
    final originalAmount = double.tryParse(amountController.text) ?? 0.0;

    // Calculate discount amount and final amount based on various factors
    double discountAmount = 0.0;
    double finalAmount = originalAmount;

    // Check if there's a discount directly in the QR code
    if (qrCode.discount != null && qrCode.discount! > 0) {
      discountAmount = qrCode.discount!;
      finalAmount = originalAmount - discountAmount;
    } else if (offer != null && activation != null) {
      // If no direct discount, calculate from offer
      final discountValue = double.tryParse(offer!.discount) ?? 0;
      final bonusValue = double.tryParse(offer!.bonus) ?? 0;

      if (discountValue > 0) {
        if (offer!.discountType == 'PERCENTAGE') {
          discountAmount = originalAmount * (discountValue / 100);
        } else {
          discountAmount = discountValue;
        }
      } else if (bonusValue > 0) {
        if (offer!.bonusType == 'PERCENTAGE') {
          discountAmount = originalAmount * (bonusValue / 100);
        } else {
          discountAmount = bonusValue;
        }
      }

      finalAmount = originalAmount - discountAmount;
    }

    if (finalAmount < 0) finalAmount = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Amount input field - only show if it's not a product list
          if (qrCode.products == null || qrCode.products!.isEmpty)
            CustomTextField(
              controller: amountController,
              labelText: 'Amount',
              enabled: enabled && qrCode.type != 'FIXED',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              icon: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  qrCode.currency,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              errorText: errorText,
            ),

          // Product list - show if available
          if (qrCode.products != null && qrCode.products!.isNotEmpty)
            _buildProductList(context, qrCode.products!, qrCode.currency),

          // Discount info
          if (discountAmount > 0) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '- ${qrCode.currency} ${discountAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Final Amount:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${qrCode.currency} ${finalAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.scrim,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Discount provided by ${offer?.merchantName ?? merchantName}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],

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

  Widget _buildProductList(
      BuildContext context, List<Product> products, String currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...products
            .map((product) => _buildProductItem(context, product, currency))
            .toList(),
      ],
    );
  }

  Widget _buildProductItem(
      BuildContext context, Product product, String currency) {
    final productPrice = product.price * product.quantity;
    final discountAmount =
        product.discount > 0 ? product.discount * product.quantity : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$currency ${product.price.toStringAsFixed(2)} × ${product.quantity}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '$currency ${productPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              if (product.discount > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '- $currency ${discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
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
  final double finalAmount;
  final String currency;

  const _ActionButtons({
    required this.onConfirm,
    required this.onCancel,
    required this.isProcessing,
    required this.finalAmount,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RectangularButton(
          label: isProcessing
              ? "Processing..."
              : "Confirm Payment of $currency ${finalAmount.toStringAsFixed(2)}",
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
