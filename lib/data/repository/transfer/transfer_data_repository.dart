import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/transfer/transfer_model.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';

class TransferDataRepository extends TransferRepository {
  final ApiUtil _apiUtil;

  TransferDataRepository(this._apiUtil);

  @override
  Future<TransferInitiate> initiateTransfer(Map<String, dynamic> data) {
    return _apiUtil.initiateTransfer(data);
  }
}
