import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'selected_locale';
  static const List<String> _supportedLocales = ['en', 'es'];

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);

    // Check if saved locale is supported
    if (savedLocale != null && _supportedLocales.contains(savedLocale)) {
      emit(Locale(savedLocale));
    } else {
      // Default to 'en' for invalid locales
      await prefs.setString(_localeKey, 'en');
      emit(const Locale('en'));
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, newLocale.languageCode);
    emit(newLocale);
  }
}
