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
      await _contactsRepository.deleteContact(phone);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
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
