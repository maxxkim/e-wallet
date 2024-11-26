import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/presentation/screen/payment/payment_confirmation_screen.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  bool _processing = false;
  bool _hasScanned = false;
  bool _hasError = false;
  String? _errorMessage;
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  Future<void> _initializeScanner() async {
    try {
      await _controller.start();
      if (mounted) {
        setState(() {
          _hasError = false;
          _errorMessage = null;
        });
      }
    } on MobileScannerException catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Camera permission is required';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processQrCode(String code) async {
    if (_processing || _hasScanned) return;

    setState(() {
      _processing = true;
      _hasScanned = true;
    });

    try {
      await _controller.stop();

      final repository = RepositoryProvider.of<QrPaymentRepository>(context);
      final response = await repository.checkQrCode(code);

      if (mounted) {
        setState(() {
          _processing = false;
        });
        _showPaymentConfirmation(repository, response);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _processing = false;
          _hasScanned = false;
        });

        _controller.start();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void _showPaymentConfirmation(
    QrPaymentRepository repository,
    QrPaymentResponse paymentDetails,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrPaymentConfirmation(
          paymentDetails: paymentDetails,
          onConfirm: (amount) async {
            try {
              await repository.processPayment(
                paymentDetails.qrCode.hash,
                amount,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Payment processed successfully!')),
                );
                Navigator.of(context).pop(); // Close confirmation
                Navigator.of(context).pop(); // Close scanner
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment failed: ${e.toString()}')),
                );
              }
            }
          },
          onCancel: () {
            setState(() {
              _hasScanned = false;
            });
            _controller.start();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_hasError) return;

    final code = barcodes.barcodes.firstOrNull?.rawValue;
    if (code != null) {
      _processQrCode(code);
    }
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'An error occurred',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeScanner,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            if (!_hasError)
              MobileScanner(
                controller: _controller,
                onDetect: _handleBarcode,
                errorBuilder: (context, error, child) {
                  // Only update error state if it's a permission error
                  if (error.errorCode ==
                      MobileScannerErrorCode.permissionDenied) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _hasError = true;
                        _errorMessage = 'Camera permission is required';
                      });
                    });
                  }
                  return const SizedBox();
                },
              ),
            if (_hasError) _buildErrorScreen(),
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
