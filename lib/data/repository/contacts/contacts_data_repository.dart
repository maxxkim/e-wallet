import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';

class ContactsDataRepository extends ContactsRepository {
  final ApiUtil _apiUtil;

  ContactsDataRepository(this._apiUtil);

  @override
  Future<List<ContactModel>> getContacts() {
    return _apiUtil.getContacts();
  }

  @override
  Future<ContactModel> addContact(String phone, String? nickname) {
    return _apiUtil.addContact(phone, nickname);
  }

  @override
  Future<ContactModel> updateContact(int id, String phone, String? nickname) {
    return _apiUtil.updateContact(id, phone, nickname);
  }

  @override
  Future<void> deleteContact(int id) {
    return _apiUtil.deleteContact(id);
  }
}
