import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';

class ContactsDataRepository extends ContactsRepository {
  final ApiUtil _apiUtil;
  ContactsDataRepository(this._apiUtil);

  @override
  Future<List<ContactModel>> getContacts() async {
    return await _apiUtil.getContacts();
  }

  @override
  Future<ContactModel> addContact(String phone, String? nickname) async {
    return await _apiUtil.addContact(phone, nickname);
  }

  @override
  Future<ContactModel> updateContact(String phone, String? nickname) async {
    return await _apiUtil.updateContact(phone, nickname);
  }

  @override
  Future<void> deleteContact(String phone) async {
    // Make sure we await this operation completely
    await _apiUtil.deleteContact(phone);

    // Add a small delay to ensure server consistency
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
