import 'package:zippy/domain/model/contacts/contact_model.dart';

abstract class ContactsRepository {
  Future<List<ContactModel>> getContacts();
  Future<ContactModel> addContact(String phone, String? nickname);
  Future<ContactModel> updateContact(int id, String phone, String? nickname);
  Future<void> deleteContact(int id);
}
