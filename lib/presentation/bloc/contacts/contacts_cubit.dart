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
      emit(ContactsStateLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  Future<void> addContact(String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());
      // Keep current contacts in view while loading
      final currentState = state;

      // Add contact
      await _contactsRepository.addContact(phone, nickname);

      // Immediately reload contacts to show updated list
      final contacts = await _contactsRepository.getContacts();
      emit(ContactsStateLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      // Restore previous state on error
      if (state is ContactsStateLoaded) {
        emit(state);
      }
    }
  }

  Future<void> updateContact(int id, String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());
      final currentState = state;

      await _contactsRepository.updateContact(id, phone, nickname);

      final contacts = await _contactsRepository.getContacts();
      emit(ContactsStateLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      if (state is ContactsStateLoaded) {
        emit(state);
      }
    }
  }

  Future<void> deleteContact(String phone) async {
    try {
      emit(ContactsStateLoading());
      final currentState = state;

      await _contactsRepository.deleteContact(phone);

      final contacts = await _contactsRepository.getContacts();
      emit(ContactsStateLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsStateError(
        errorMessage: _handleError(e),
      ));
      if (state is ContactsStateLoaded) {
        emit(state);
      }
    }
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'Oopsie! Something went wrong: ${error.toString()} >.<';
    }
    return 'Unknown error occurred nyaa~ Please try again! UwU';
  }
}
