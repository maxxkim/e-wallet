import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _contactsRepository;
  String? lastMessage;

  ContactsCubit(this._contactsRepository) : super(ContactsStateLoading()) {
    loadContacts();
  }

  Future<void> loadContacts() async {
    try {
      emit(ContactsStateLoading());
      final contacts = await _contactsRepository.getContacts();
      emit(ContactsStateLoaded(
        contacts: contacts,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  Future<void> addContact(String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());
      String? message = await _contactsRepository.addContact(phone, nickname);
      if (message != null) {
        lastMessage = message;
      } else {
        lastMessage = "Success!";
      }
      await loadContacts();
    } catch (e) {
      lastMessage = _handleError(e); // Store the error message
      emit(ContactsStateError(
        errorMessage: lastMessage!,
      ));
      await loadContacts();
    }
  }

  Future<void> updateContact(String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());
      await _contactsRepository.updateContact(phone, nickname);
      lastMessage =
          "Contact updated successfully! UwU"; // Success message for update
      await loadContacts();
    } catch (e) {
      lastMessage = _handleError(e);
      emit(ContactsStateError(
        errorMessage: lastMessage!,
      ));
      await loadContacts();
    }
  }

  Future<void> deleteContact(String phone) async {
    try {
      emit(ContactsStateLoading());
      await _contactsRepository.deleteContact(phone);
      lastMessage =
          "Contact deleted successfully! OwO"; // Success message for delete
      await loadContacts();
    } catch (e) {
      lastMessage = _handleError(e);
      emit(ContactsStateError(
        errorMessage: lastMessage!,
      ));
      await loadContacts();
    }
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'Oopsie! Something went wrong: ${error.toString()} >.<';
    }
    return 'Unknown error occurred nyaa~ Please try again! UwU';
  }
}
