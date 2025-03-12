import 'package:flutter/services.dart';

/// A TextInputFormatter that prevents deletion of the country code prefix
class CountryCodeFormatter extends TextInputFormatter {
  final String countryCode;

  CountryCodeFormatter(this.countryCode);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If attempting to delete the country code
    if (newValue.text.length < countryCode.length) {
      return TextEditingValue(
        text: countryCode,
        selection: TextSelection.collapsed(offset: countryCode.length),
      );
    }

    // If replacing text that includes the country code
    if (newValue.text.length >= countryCode.length &&
        !newValue.text.startsWith(countryCode)) {
      return TextEditingValue(
        text: countryCode +
            newValue.text.substring(newValue.text.length -
                (newValue.text.length - oldValue.text.length)),
        selection: TextSelection.collapsed(offset: countryCode.length),
      );
    }

    return newValue;
  }
}
