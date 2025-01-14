import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:zippy/domain/state/transfer/contact_picker_state.dart';

class ContactPickerCubit extends Cubit<ContactPickerState> {
  ContactPickerCubit() : super(ContactPickerInitial());

  Future<void> pickContact() async {
    try {
      // Request permission first
      if (await FlutterContacts.requestPermission()) {
        // Open contact picker if permission granted
        final contact = await FlutterContacts.openExternalPick();

        if (contact != null) {
          // Get full contact details including phone numbers
          final fullContact = await FlutterContacts.getContact(contact.id);

          if (fullContact?.phones.isNotEmpty == true) {
            // Get first phone number and format it
            String phoneNumber = fullContact!.phones.first.number
                .replaceAll(RegExp(r'[^\d+]'), '');

            if (!phoneNumber.startsWith('+')) {
              phoneNumber = '+$phoneNumber';
            }

            emit(ContactSelected(phoneNumber: phoneNumber));
          }
        }
      } else {
        // Handle permission denied
        print("Contact permission denied");
        emit(ContactPickerInitial());
      }
    } catch (e) {
      print("Error picking contact: $e");
      emit(ContactPickerInitial());
    }
  }
}
