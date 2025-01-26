// ./lib/data/repository/transfer/transfer_data_repository.dart
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/transfer/transfer_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';

class TransferDataRepository extends TransferRepository {
  final ApiUtil _apiUtil;
  TransferDataRepository(this._apiUtil);

  @override
  Future<TransferInitiate> initiateTransfer(Map<String, dynamic> data) {
    return _apiUtil.initiateTransfer(data);
  }

  @override
  Future<List<ContactModel>> getRecentContacts() {
    return _apiUtil.getRecentContacts();
  }
}
