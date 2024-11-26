// lib/presentation/widget/barcode_scanner_simple.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  Barcode? _barcode;
  bool _processing = false;
  final TextEditingController _amountController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void dispose() {
    _controller.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (_processing) return;

    setState(() {
      _processing = true;
    });

    try {
      final repository = RepositoryProvider.of<QrPaymentRepository>(context);
      final response = await repository.checkQrCode(code);

      if (mounted) {
        if (response.qrCode.type == 'FIXED') {
          await _processFixedPayment(repository, response.qrCode);
        } else {
          await _showAmountDialog(repository, response.qrCode);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _processing = false;
        });
      }
    }
  }

  Future<void> _processFixedPayment(
      QrPaymentRepository repository, QrCode qrCode) async {
    try {
      await repository.processPayment(qrCode.hash, qrCode.amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment processed successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showAmountDialog(
      QrPaymentRepository repository, QrCode qrCode) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Amount'),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter amount",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(_amountController.text);
              if (amount != null) {
                try {
                  await repository.processPayment(qrCode.hash, amount);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Payment processed successfully!')),
                    );
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Close scanner
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Payment failed: ${e.toString()}')),
                    );
                  }
                }
              }
            },
            child: const Text('Pay'),
          ),
        ],
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final code = barcodes.barcodes.firstOrNull?.rawValue;
    if (code != null && !_processing) {
      _processQrCode(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
              errorBuilder: (context, error, child) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Camera permission is required',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await _controller.start();
                        },
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                );
              },
            ),
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_processing)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
