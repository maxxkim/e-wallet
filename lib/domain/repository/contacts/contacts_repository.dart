import 'package:zippy/domain/model/contacts/contact_model.dart';

abstract class ContactsRepository {
  Future<List<ContactModel>> getContacts();
  Future<String?> addContact(String phone, String? nickname);
  Future<ContactModel> updateContact(String phone, String? nickname);
  Future<void> deleteContact(String phone);
}
