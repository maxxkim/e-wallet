import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class PhoneMaskHelper {
  static final SecureStorageService _secureStorage = SecureStorageService();

  static Future<void> savePhoneMaskInfo(CountryModel country) async {
    await _secureStorage.savePhoneMaskInfo(
        country.phoneMask, country.phonePattern, country.code);
  }

  static Future<MaskTextInputFormatter> getMaskFormatter() async {
    final mask = await _secureStorage.getPhoneMask() ?? "+# (###) ### ## ##";
    return MaskTextInputFormatter(
      mask: mask,
      filter: {"#": RegExp(r'[0-9]')},
    );
  }

  static Future<String> getPhonePattern() async {
    return await _secureStorage.getPhonePattern() ?? r'^\+[0-9]{8,15}$';
  }

  static Future<String> getCountryCode() async {
    return await _secureStorage.getCountryCode() ?? 'CL';
  }

  static Future<String> formatPhoneNumber(String rawPhoneNumber) async {
    final formatter = await getMaskFormatter();

    String cleanPhone = rawPhoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

    if (!cleanPhone.startsWith('+')) {
      cleanPhone = '+$cleanPhone';
    }

    return formatter.maskText(cleanPhone);
  }

  static Future<bool> isValidPhone(String phoneNumber) async {
    final pattern = await getPhonePattern();
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(cleanPhone);
  }
}
