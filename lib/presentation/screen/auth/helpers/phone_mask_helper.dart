import 'package:shared_preferences/shared_preferences.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/auth/country_model.dart';

class PhoneMaskHelper {
  static const String _phoneMaskKey = 'phone_mask';
  static const String _phonePatternKey = 'phone_pattern';
  static const String _countryCodeKey = 'country_code';

  // Save phone mask information after authentication
  static Future<void> savePhoneMaskInfo(CountryModel country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_phoneMaskKey, country.phoneMask);
    await prefs.setString(_phonePatternKey, country.phonePattern);
    await prefs.setString(_countryCodeKey, country.code);
  }

  // Get the phone mask formatter for consistent formatting
  static Future<MaskTextInputFormatter> getMaskFormatter() async {
    final prefs = await SharedPreferences.getInstance();
    final mask = prefs.getString(_phoneMaskKey) ?? "+# (###) ### ## ##";

    return MaskTextInputFormatter(
      mask: mask,
      filter: {"#": RegExp(r'[0-9]')},
    );
  }

  // Get the phone validation pattern
  static Future<String> getPhonePattern() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phonePatternKey) ?? r'^\+[0-9]{8,15}$';
  }

  // Get saved country code
  static Future<String> getCountryCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_countryCodeKey) ?? 'CL';
  }

  // Format a phone number according to the saved mask
  static Future<String> formatPhoneNumber(String rawPhoneNumber) async {
    final formatter = await getMaskFormatter();

    // Clean the input of any non-numeric and '+' characters
    String cleanPhone = rawPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    // If the phone doesn't have a leading '+', add it
    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }

    // Apply the mask
    return formatter.maskText(cleanPhone);
  }

  // Validate a phone number against the saved pattern
  static Future<bool> isValidPhone(String phoneNumber) async {
    final pattern = await getPhonePattern();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(cleanPhone);
  }
}
