// ./lib/presentation/bloc/contacts/contacts_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/contacts/contacts_repository.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';

class ContactsCubit extends Cubit<ContactsState> {
  final ContactsRepository _contactsRepository;

  ContactsCubit(this._contactsRepository) : super(ContactsStateLoading());

  Future<void> loadContacts() async {
    try {
      emit(ContactsStateLoading());
      final contacts = await _contactsRepository.getContacts();
      emit(ContactsStateLoaded(contacts: contacts));
    } catch (e) {
      emit(ContactsStateError(errorMessage: e.toString()));
    }
  }

  Future<void> addContact(String phone, String? nickname) async {
    try {
      await _contactsRepository.addContact(phone, nickname);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(errorMessage: e.toString()));
    }
  }

  Future<void> updateContact(int id, String phone, String? nickname) async {
    try {
      await _contactsRepository.updateContact(id, phone, nickname);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(errorMessage: e.toString()));
    }
  }

  Future<void> deleteContact(int id) async {
    try {
      await _contactsRepository.deleteContact(id);
      await loadContacts();
    } catch (e) {
      emit(ContactsStateError(errorMessage: e.toString()));
    }
  }
}
