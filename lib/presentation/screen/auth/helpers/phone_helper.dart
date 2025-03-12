import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/auth/country_model.dart';

/// A helper class for phone number validation and formatting
class PhoneHelper {
  /// Extracts country code from a given country model
  static String extractCountryCode(CountryModel country) {
    // For Chile, return just +56 without the 9
    if (country.code == 'CL') {
      return '+56';
    }

    // Regular extraction logic for other countries
    if (country.phoneMask.contains('+')) {
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phoneMask);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    if (country.phonePattern.contains('+')) {
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phonePattern);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    if (country.phoneExample.startsWith('+')) {
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phoneExample);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    return '+${country.code.substring(0, 1)}';
  }

  /// Creates a MaskTextInputFormatter with the country code protected
  static MaskTextInputFormatter createPhoneFormatter(CountryModel country) {
    String countryCode = extractCountryCode(country);
    String mask = country.phoneMask;

    // Ensure mask starts with '+'
    if (!mask.startsWith('+')) {
      mask = '+$mask';
    }

    return MaskTextInputFormatter(
      mask: mask,
      filter: {"#": RegExp(r'[0-9]')},
      initialText: countryCode,
    );
  }

  /// Validates a phone number against a country's pattern
  static bool validatePhone(String phone, CountryModel country) {
    // Clean the phone number first
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Make sure the phone starts with '+'
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }

    // Use the pattern from the country model
    final RegExp regex = RegExp(country.phonePattern);
    return regex.hasMatch(cleanPhone);
  }

  /// Formats a phone number for API submission
  static String formatForApi(String phone) {
    // Remove spaces and other non-essential characters
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  /// Creates a TextInputFormatter that prevents deletion of the country code
  static TextInputFormatter createCountryCodeProtector(String countryCode) {
    return _CountryCodeProtectionFormatter(countryCode.length);
  }
}

/// A TextInputFormatter that prevents deletion of a specified number of characters
/// from the beginning of the text field
class _CountryCodeProtectionFormatter extends TextInputFormatter {
  final int protectedLength;

  _CountryCodeProtectionFormatter(this.protectedLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If text is being deleted and would affect the protected part
    if (newValue.text.length < protectedLength) {
      // Restore the protected part from the old value
      String protectedPart = oldValue.text.substring(0, protectedLength);
      String remainingPart = '';

      // If the new value is not empty and not just the protected part being deleted
      if (newValue.text.isNotEmpty) {
        remainingPart = newValue.text;
      }

      return TextEditingValue(
        text: protectedPart + remainingPart,
        selection: TextSelection.collapsed(
            offset: protectedPart.length + remainingPart.length),
      );
    }

    return newValue;
  }
}
