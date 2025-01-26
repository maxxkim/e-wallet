import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsCubit(this._contactsRepository) : super(ContactsStateLoading()) {
    loadContacts(); // Load contacts when cubit is created >w
  }

  Future<void> loadContacts() async {
    try {
      emit(ContactsStateLoading());
      final contacts = await _contactsRepository.getContacts();

      if (!isClosed) {
        emit(ContactsStateLoaded(contacts: contacts));
      }
    } catch (e) {
      if (!isClosed) {
        emit(ContactsStateError(
          errorMessage: _handleError(e),
        ));
      }
    }
  }

  Future<void> addContact(String phone, String? nickname) async {
    try {
      final currentState = state;
      emit(ContactsStateLoading());

      await _contactsRepository.addContact(phone, nickname);
      await loadContacts(); // Refresh the contacts list uwu
    } catch (e) {
      if (!isClosed) {
        emit(ContactsStateError(
          errorMessage: _handleError(e),
        ));
      }
    }
  }

  Future<void> updateContact(int id, String phone, String? nickname) async {
    try {
      emit(ContactsStateLoading());

      await _contactsRepository.updateContact(id, phone, nickname);
      await loadContacts(); // Keep our list fresh nya~
    } catch (e) {
      if (!isClosed) {
        emit(ContactsStateError(
          errorMessage: _handleError(e),
        ));
      }
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      emit(ContactsStateLoading());

      await _contactsRepository.deleteContact(id);
      await loadContacts(); // Make sure list is up-to-date :3
    } catch (e) {
      if (!isClosed) {
        emit(ContactsStateError(
          errorMessage: _handleError(e),
        ));
      }
    }
  }

  String _handleError(dynamic error) {
    // Kawaii error handling UwU
    if (error is Exception) {
      return 'Oopsie! Something went wrong: ${error.toString()} >.<';
    }
    return 'Unknown error occurred nyaa~ Please try again! uwu';
  }
}
