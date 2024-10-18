import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTheme { light, dark }

class ThemeCubit extends Cubit<AppTheme> {
  ThemeCubit() : super(AppTheme.light);

  // Метод для переключения темы
  void toggleTheme() {
    emit(state == AppTheme.light ? AppTheme.dark : AppTheme.light);
  }

  // Метод для проверки, является ли текущая тема темной
  bool get isDarkMode => state == AppTheme.dark;
}