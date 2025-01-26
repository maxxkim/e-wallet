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
    if (state is ContactsStateLoaded) {
      final currentContacts = (state as ContactsStateLoaded).contacts;
      try {
        final newContact =
            await _contactsRepository.addContact(phone, nickname);
        if (!isClosed) {
          emit(ContactsStateLoaded(contacts: [...currentContacts, newContact]));
        }
      } catch (e) {
        if (!isClosed) {
          emit(ContactsStateError(
            errorMessage: _handleError(e),
          ));
          // Restore previous state after error
          emit(ContactsStateLoaded(contacts: currentContacts));
        }
      }
    }
  }

  Future<void> updateContact(int id, String phone, String? nickname) async {
    if (state is ContactsStateLoaded) {
      final currentContacts = (state as ContactsStateLoaded).contacts;
      try {
        final updatedContact =
            await _contactsRepository.updateContact(id, phone, nickname);
        if (!isClosed) {
          final updatedContacts = currentContacts
              .map((contact) => contact.id == id ? updatedContact : contact)
              .toList();
          emit(ContactsStateLoaded(contacts: updatedContacts));
        }
      } catch (e) {
        if (!isClosed) {
          emit(ContactsStateError(
            errorMessage: _handleError(e),
          ));
          // Restore previous state after error
          emit(ContactsStateLoaded(contacts: currentContacts));
        }
      }
    }
  }

  Future<void> deleteContact(String phone) async {
    if (state is ContactsStateLoaded) {
      final currentContacts = (state as ContactsStateLoaded).contacts;
      try {
        await _contactsRepository.deleteContact(phone);
        if (!isClosed) {
          final updatedContacts = currentContacts
              .where((contact) => contact.name != phone)
              .toList();
          emit(ContactsStateLoaded(contacts: updatedContacts));
        }
      } catch (e) {
        if (!isClosed) {
          emit(ContactsStateError(
            errorMessage: _handleError(e),
          ));
          // Restore previous state after error
          emit(ContactsStateLoaded(contacts: currentContacts));
        }
      }
    }
  }

  String _handleError(dynamic error) {
    if (error is Exception) {
      return 'Oopsie! Something went wrong: ${error.toString()} >.<';
    }
    return 'Unknown error occurred nyaa~ Please try again! uwu';
  }
}
