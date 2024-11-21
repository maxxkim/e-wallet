import 'package:zippy/data/api/api_transfer_initiate.dart';
import 'package:zippy/domain/model/transfer/transfer_model.dart';

class TransferInitiateMapper {
  static TransferInitiate fromApi(ApiTransferInitiate transferInitiate) {
    return TransferInitiate(
      transferHash: transferInitiate.transferHash,
      wallet: transferInitiate.wallet,
      status: transferInitiate.status,
    );
  }
}
