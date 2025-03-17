import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:zippy/internal/services/secure_storage_service.dart';

class LocaleCubit extends Cubit<Locale> {
  final SecureStorageService _secureStorage = SecureStorageService();

  LocaleCubit() : super(const Locale('en')) {
    _loadSavedLocale();
  }

  static const List<String> _supportedLocales = ['en', 'es'];

  Future<void> _loadSavedLocale() async {
    final savedLocale = await _secureStorage.getLocale();

    if (savedLocale != null && _supportedLocales.contains(savedLocale)) {
      emit(Locale(savedLocale));
    } else {
      await _secureStorage.saveLocale('en');
      emit(const Locale('en'));
    }
  }

  Future<void> changeLocale(Locale newLocale) async {
    await _secureStorage.saveLocale(newLocale.languageCode);
    emit(newLocale);
  }
}
