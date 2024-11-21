import 'package:zippy/domain/model/transfer/transfer_model.dart';

abstract class TransferRepository {
  Future<TransferInitiate> initiateTransfer(Map<String, dynamic> data);
}
