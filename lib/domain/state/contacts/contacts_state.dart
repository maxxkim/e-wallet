import 'package:zippy/domain/model/contacts/contact_model.dart';

abstract class ContactsState {}

class ContactsStateLoading extends ContactsState {}

class ContactsStateLoaded extends ContactsState {
  final List<ContactModel> contacts;
  final int timestamp; // Add timestamp to force state change

  ContactsStateLoaded({
    required this.contacts,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactsStateLoaded &&
          timestamp == other.timestamp; // Compare timestamps

  @override
  int get hashCode => timestamp.hashCode;
}

class ContactsStateError extends ContactsState {
  final String errorMessage;

  ContactsStateError({required this.errorMessage});
}
