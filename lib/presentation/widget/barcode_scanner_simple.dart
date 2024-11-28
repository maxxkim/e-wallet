import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';
import 'package:zippy/presentation/bloc/qr/qr_payment_cubit.dart';
import 'package:zippy/presentation/screen/payment/payment_confirmation_screen.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              onDetect: (barcodes) async {
                final code = barcodes.barcodes.firstOrNull?.rawValue;
                if (code != null) {
                  // Stop scanning while processing
                  _controller.stop();

                  // Create a new cubit for each scan
                  final qrPaymentCubit = QrPaymentCubit(
                    RepositoryProvider.of<QrPaymentRepository>(context),
                  );

                  try {
                    // Process the QR code
                    await qrPaymentCubit.processQrCode(code);

                    // Check the state after processing
                    final currentState = qrPaymentCubit.state;
                    if (currentState is QrPaymentScanSuccess) {
                      if (mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlocProvider.value(
                              value: qrPaymentCubit,
                              child: QrPaymentConfirmation(
                                paymentDetails: currentState.qrPaymentResponse,
                                onConfirm: (amount) async {
                                  await qrPaymentCubit.processPayment(
                                    currentState.qrPaymentResponse,
                                    amount.toString(),
                                  );
                                },
                                onCancel: () {
                                  qrPaymentCubit.close();
                                  context.go(
                                      '/dashboard'); // Nya~ Redirecting to dashboard!
                                },
                              ),
                            ),
                          ),
                        );
                      }
                    } else if (currentState is QrPaymentScanError && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(currentState.message)),
                      );
                    }
                  } finally {
                    // Resume scanning after processing (if still mounted)
                    if (mounted) {
                      _controller.start();
                    }
                  }
                }
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
                onPressed: () => context.go(
                    '/dashboard'), // UwU Back button also goes to dashboard~
              ),
            ),
          ],
        ),
      ),
    );
  }
}
