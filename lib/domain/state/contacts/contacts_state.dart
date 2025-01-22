import 'package:zippy/domain/model/contacts/contact_model.dart';

abstract class ContactsState {}

class ContactsStateLoading extends ContactsState {}

class ContactsStateLoaded extends ContactsState {
  final List<ContactModel> contacts;

  ContactsStateLoaded({required this.contacts});
}

class ContactsStateError extends ContactsState {
  final String errorMessage;

  ContactsStateError({required this.errorMessage});
}
