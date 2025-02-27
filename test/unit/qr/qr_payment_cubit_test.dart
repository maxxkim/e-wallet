import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zippy/domain/model/qr/payment_response_model.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/repository/qr/qr_payment_repository.dart';
import 'package:zippy/domain/state/qr/qr_payment_state.dart';
import 'package:zippy/presentation/bloc/qr/qr_payment_cubit.dart';
import 'qr_payment_cubit_test.mocks.dart';

@GenerateMocks([QrPaymentRepository])
void main() {
  late QrPaymentRepository mockQrPaymentRepository;
  late QrPaymentCubit qrPaymentCubit;

  setUp(() {
    mockQrPaymentRepository = MockQrPaymentRepository();
    qrPaymentCubit = QrPaymentCubit(mockQrPaymentRepository);
  });

  tearDown(() {
    qrPaymentCubit.close();
  });

  group('QrPaymentCubit Tests', () {
    const testQrCode = 'test_qr_code';
    const testAmount = '100.0';

    final testQrPaymentResponse = QrPaymentResponse(
      status: 'success',
      qrCode: QrCode(
        hash: 'test_hash',
        currency: 'USD',
        amount: 100.0,
        type: 'FIXED',
        status: 'active',
        isTemporary: 0,
      ),
      merchant: QrMerchant(
        name: 'Test Merchant',
        url: 'https://example.com',
      ),
    );

    final testPaymentResponse = PaymentResponse(
      status: 'success',
      payment: Payment(
        hash: 'test_hash',
        currency: 'USD',
        amount: 100.0,
        status: 'completed',
      ),
      wallet: Wallet(
        hash: 'wallet_hash',
        currency: 'USD',
        balance: 1000.0,
        reserve: 0.0,
      ),
    );

    test('initial state is QrPaymentInitial', () {
      expect(qrPaymentCubit.state, isA<QrPaymentInitial>());
    });

    blocTest<QrPaymentCubit, QrPaymentState>(
      'startScanning emits QrPaymentScanning',
      build: () => qrPaymentCubit,
      act: (cubit) => cubit.startScanning(),
      expect: () => [isA<QrPaymentScanning>()],
    );

    blocTest<QrPaymentCubit, QrPaymentState>(
      'processQrCode emits [QrPaymentLoading, QrPaymentScanSuccess] when successful',
      setUp: () {
        when(mockQrPaymentRepository.checkQrCode(testQrCode))
            .thenAnswer((_) async => testQrPaymentResponse);
      },
      build: () => qrPaymentCubit,
      act: (cubit) => cubit.processQrCode(testQrCode),
      expect: () => [
        isA<QrPaymentLoading>(),
        isA<QrPaymentScanSuccess>().having(
          (state) => state.qrPaymentResponse,
          'qrPaymentResponse',
          testQrPaymentResponse,
        ),
      ],
      verify: (_) {
        verify(mockQrPaymentRepository.checkQrCode(testQrCode)).called(1);
      },
    );

    blocTest<QrPaymentCubit, QrPaymentState>(
      'processQrCode emits [QrPaymentLoading, QrPaymentScanError] when error occurs',
      setUp: () {
        when(mockQrPaymentRepository.checkQrCode(testQrCode))
            .thenThrow(Exception('QR code processing failed'));
      },
      build: () => qrPaymentCubit,
      act: (cubit) => cubit.processQrCode(testQrCode),
      expect: () => [
        isA<QrPaymentLoading>(),
        isA<QrPaymentScanError>().having(
          (state) => state.message,
          'error message',
          'Exception: QR code processing failed',
        ),
      ],
    );

    blocTest<QrPaymentCubit, QrPaymentState>(
      'processPayment emits success state when payment is processed successfully',
      setUp: () {
        when(mockQrPaymentRepository.processPayment(
          testQrPaymentResponse.qrCode.hash,
          double.parse(testAmount),
        )).thenAnswer((_) async => testPaymentResponse);
      },
      build: () => qrPaymentCubit,
      seed: () =>
          QrPaymentScanSuccess(qrPaymentResponse: testQrPaymentResponse),
      act: (cubit) => cubit.processPayment(testQrPaymentResponse, testAmount),
      expect: () => [
        isA<QrPaymentScanSuccess>()
            .having((state) => state.isProcessing, 'isProcessing', true),
        isA<QrPaymentSuccess>().having(
          (state) => state.paymentResponse,
          'paymentResponse',
          testPaymentResponse,
        ),
      ],
      verify: (_) {
        verify(mockQrPaymentRepository.processPayment(
          testQrPaymentResponse.qrCode.hash,
          double.parse(testAmount),
        )).called(1);
      },
    );

    blocTest<QrPaymentCubit, QrPaymentState>(
      'processPayment emits error state when payment processing fails',
      setUp: () {
        when(mockQrPaymentRepository.processPayment(
          testQrPaymentResponse.qrCode.hash,
          double.parse(testAmount),
        )).thenThrow(Exception('Payment processing failed'));
      },
      build: () => qrPaymentCubit,
      seed: () =>
          QrPaymentScanSuccess(qrPaymentResponse: testQrPaymentResponse),
      act: (cubit) => cubit.processPayment(testQrPaymentResponse, testAmount),
      expect: () => [
        isA<QrPaymentScanSuccess>()
            .having((state) => state.isProcessing, 'isProcessing', true),
        isA<QrPaymentProcessError>().having(
          (state) => state.message,
          'error message',
          'Exception: Payment processing failed',
        ),
        isA<QrPaymentScanSuccess>()
            .having((state) => state.isProcessing, 'isProcessing', false),
      ],
    );

    blocTest<QrPaymentCubit, QrPaymentState>(
      'resetScanner emits QrPaymentScanning',
      build: () => qrPaymentCubit,
      act: (cubit) => cubit.resetScanner(),
      expect: () => [isA<QrPaymentScanning>()],
    );
  });
}
