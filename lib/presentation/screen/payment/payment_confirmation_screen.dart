import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class QrPaymentConfirmation extends StatefulWidget {
  final QrPaymentResponse paymentDetails;
  final Function(double amount) onConfirm;
  final VoidCallback onCancel;
  final bool isProcessing;

  const QrPaymentConfirmation({
    Key? key,
    required this.paymentDetails,
    required this.onConfirm,
    required this.onCancel,
    this.isProcessing = false,
  }) : super(key: key);

  @override
  State<QrPaymentConfirmation> createState() => _QrPaymentConfirmationState();
}

class _QrPaymentConfirmationState extends State<QrPaymentConfirmation>
    with FadeInAnimationMixin {
  final TextEditingController _amountController = TextEditingController();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _amountController.text =
        widget.paymentDetails.qrCode.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndConfirm() {
    if (widget.paymentDetails.qrCode.type == 'FIXED') {
      widget.onConfirm(widget.paymentDetails.qrCode.amount);
      return;
    }

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _errorText = 'Please enter an amount';
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorText = 'Please enter a valid amount';
      });
      return;
    }

    widget.onConfirm(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onCancel,
        ),
        title: Text(
          'Payment Confirmation',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: staggeredFadeIn([
              const SizedBox(height: 24),
              _MerchantInfoCard(merchant: widget.paymentDetails.merchant),
              const SizedBox(height: 24),
              _PaymentDetailsCard(
                qrCode: widget.paymentDetails.qrCode,
                amountController: _amountController,
                errorText: _errorText,
              ),
              const SizedBox(height: 32),
              _ActionButtons(
                onConfirm: _validateAndConfirm,
                onCancel: widget.onCancel,
                isProcessing: widget.isProcessing,
              ),
            ]),
          ),
        ),
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
          SvgPicture.asset(
            'assets/images/icon_merchant.svg',
            height: 48,
            width: 48,
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

  const _PaymentDetailsCard({
    required this.qrCode,
    required this.amountController,
    this.errorText,
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
            enabled: qrCode.type != 'FIXED',
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
