import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _contactsRepository;
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
      await _contactsRepository.addContact(phone, nickname);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      await loadContacts();
    }
  }

  Future<void> updateContact(String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());
      await _contactsRepository.updateContact(phone, nickname);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      await loadContacts();
    }
  }

  Future<void> deleteContact(String phone) async {
    try {
      emit(ContactsStateLoading());
      // This is a synchronous operation - wait for it to complete
      await _contactsRepository.deleteContact(phone);

      // We're not trying to refresh the list anymore,
      // as we'll redirect to another screen and handle UI refresh there
      emit(ContactsStateLoaded(
        contacts: [], // Empty list since we're navigating away anyway
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      throw e; // Rethrow so we can catch it in the UI
    }
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'Oopsie! Something went wrong: ${error.toString()} >.<';
    }
    return 'Unknown error occurred nyaa~ Please try again! UwU';
  }
}
