// ./test/unit/transfer/transfer_cubit_test.dart

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zippy/domain/model/transfer/transfer_model.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'transfer_cubit_test.mocks.dart';

@GenerateMocks([TransferRepository])
void main() {
  late TransferCubit transferCubit;
  late TransferRepository mockTransferRepository;

  setUp(() {
    mockTransferRepository = MockTransferRepository();
    transferCubit = TransferCubit(mockTransferRepository);
  });

  tearDown(() {
    transferCubit.close();
  });

  group('TransferCubit Tests', () {
    final testTransferData = {
      'recipient': '+56912345678',
      'amount': 100.0,
    };

    final testTransferResponse = TransferInitiate(
      transferHash: 'test_hash',
      status: 'success',
      wallet: {'balance': 1000.0},
    );

    blocTest<TransferCubit, TransferState>(
      'initializeTransfer emits TransferStateSuccess when successful',
      setUp: () {
        when(mockTransferRepository.initiateTransfer(testTransferData))
            .thenAnswer((_) async => testTransferResponse);
      },
      build: () => transferCubit,
      act: (cubit) => cubit.initializeTransfer(testTransferData),
      expect: () => [isA<TransferStateSuccess>()],
      verify: (_) {
        verify(mockTransferRepository.initiateTransfer(testTransferData))
            .called(1);
      },
    );

    blocTest<TransferCubit, TransferState>(
      'initializeTransfer emits TransferStateError with isRecipientNotFound true when recipient not found',
      setUp: () {
        when(mockTransferRepository.initiateTransfer(testTransferData))
            .thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          response: Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 404,
          ),
        ));
      },
      build: () => transferCubit,
      act: (cubit) => cubit.initializeTransfer(testTransferData),
      expect: () => [
        isA<TransferStateError>().having(
            (state) => state.isRecipientNotFound, 'isRecipientNotFound', true)
      ],
    );
  });
}
