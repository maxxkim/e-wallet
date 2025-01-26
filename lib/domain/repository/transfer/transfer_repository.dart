// ./lib/domain/repository/transfer/transfer_repository.dart
import 'package:zippy/domain/model/transfer/transfer_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';

abstract class TransferRepository {
  Future<TransferInitiate> initiateTransfer(Map<String, dynamic> data);
  Future<List<ContactModel>> getRecentContacts(); // Added this kawaii method >w
}
