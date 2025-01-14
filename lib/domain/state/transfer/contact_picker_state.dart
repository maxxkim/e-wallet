abstract class ContactPickerState {}

class ContactPickerInitial extends ContactPickerState {}

class ContactSelected extends ContactPickerState {
  final String phoneNumber;

  ContactSelected({required this.phoneNumber});
}
