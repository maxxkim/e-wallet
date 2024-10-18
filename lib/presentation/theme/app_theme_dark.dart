import 'package:flutter/material.dart';

const Color blackColor = Colors.red;
const Color aquamarineColor = Colors.pink;
const Color bluePurpleColor = Colors.green;
const Color darkGreyColor = Colors.orange;
const Color lightGreyColor = Colors.black;
const Color lightAquamarineColor = Colors.purple;
const Color midLightAquamarineColor = Colors.yellow;
const Color greenColor = Colors.teal;
const Color redColor = Colors.lime;
const Color whiteColor = Colors.amber;

final ThemeData appThemeDark = ThemeData(
  primaryColor: aquamarineColor,
  brightness: Brightness.light,
  scaffoldBackgroundColor: whiteColor,

  textTheme: const TextTheme(
    bodySmall: TextStyle(color: whiteColor, fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
    bodyMedium: TextStyle(color: whiteColor, fontSize: 14, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
    bodyLarge: TextStyle(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
    headlineSmall: TextStyle(color: whiteColor, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Roboto'),
    headlineMedium: TextStyle(color: whiteColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
    labelSmall: TextStyle(color: whiteColor, fontSize: 12, fontWeight: FontWeight.w300),
  ),

  colorScheme: const ColorScheme.light(
    primary: bluePurpleColor,
    secondary: whiteColor, 
  ), 
  
  appBarTheme: const AppBarTheme(
    backgroundColor: bluePurpleColor,
    foregroundColor: whiteColor,
  ),

  buttonTheme: ButtonThemeData(
    buttonColor: bluePurpleColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15.0),
    ),
    padding: const EdgeInsets.symmetric(vertical: 16.0),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(bluePurpleColor),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16.0)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: whiteColor,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: darkGreyColor, width: 1),
      borderRadius: BorderRadius.circular(15.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: darkGreyColor, width: 1),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: bluePurpleColor, width: 1),
      borderRadius: BorderRadius.circular(15.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: redColor, width: 1),
      borderRadius: BorderRadius.circular(15.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: redColor, width: 1),
      borderRadius: BorderRadius.circular(15.0),
    ),
    hintStyle: const TextStyle(color: lightGreyColor, fontWeight: FontWeight.w300),
  ),

  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(bluePurpleColor),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8.0)),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: bluePurpleColor, width: 1),
        ),
      ),
    ),
  ),

  sliderTheme: SliderThemeData(
    activeTrackColor: midLightAquamarineColor,
    inactiveTrackColor: lightAquamarineColor,
    thumbColor: bluePurpleColor,
    overlayColor: bluePurpleColor.withOpacity(0.2),
  ),

  cardColor: lightAquamarineColor,
  dialogBackgroundColor: lightGreyColor,
);

// Основные цвета брендбука:
// blackColor 1D1D1B
// aquamarineColor 52DAC6
// bluePurpleColor 0F0A54

// Дополнительные цвета для светлой темы:
// darkGreyColor 878787
// lightGreyColor EFEFEF
// lightAquamarineColor DDEEEB
// greenColor 4DD0A1
// redColor DC4949
// midLightAquamarineColor 8BD8CD
// whiteColor FFFFFF

// Шрифты:
// Roboto black w800, bold, light w300

// Использование в интерфейсе:
// Основной цвет фона: whiteColor
// (Этот цвет используется в качестве фонового цвета для всех экранов и областей, где нет дополнительных акцентов)

// Активная кнопка / важная кнопка: bluePurpleColor, font weight bold, font size 16, padding top and bottom 16px, text color whiteColor, border radius 15px

// Неактивная кнопка: border color aquamarineColor, border size 1px, font weight w300, padding top and bottom 16px, text color aquamarineColor, border radius 15px

// Поле ввода: border color darkGreyColor, border size 1px, font weight w300, padding top and bottom 16px, border radius 15px

// Неправильный ввод: border color redColor, border size 1px, font weight w300, padding top and bottom 16px, border radius 15px

// Правильный ввод: border color greenColor, border size 1px, font weight w300, padding top and bottom 16px, border radius 15px

// Кнопки фильтров:
// Активная кнопка / важная кнопка: bluePurpleColor, font weight bold, font size 12px, padding top and bottom 8px, text color whiteColor, border radius 15px

// Неактивная кнопка: border color bluePurpleColor, border size 1px, font weight w300, padding top and bottom 8px, text color bluePurpleColor, border radius 15px

// Текст:
// Цвет текста по умолчанию: blackColor

// Описание (маленький текст): font weight w300, font size 12px

// Описание (обычный текст): font weight w300, font size 14px

// Заголовки: font weight w300, font size 16px

// Основные числа: font weight bold, font size 20px

// Маленькие кнопки: font weight bold, font size 8px

// Плейсхолдер в поле ввода: color lightGreyColor

// Активное поле ввода: color blackColor

// Неактивное поле ввода: darkGreyColor

// Тексты транзакций:
// Заголовок транзакции: font weight bold, font size 10px, color bluePurpleColor

// Текст транзакции: font weight w300, font size 8px, color blackColor

// Сумма дохода: weight bold, font size 12px, color greenColor

// Сумма расходов: weight bold, font size 12px, color redColor

// Слайдеры и скроллы:
// Цвет фона: midLightAquamarineColor

// Дашборды:
// Цвет фона: lightAquamarineColor
// (Фоновый цвет для информационных панелей и кнопок-виджетов)

// Информационные блоки:
// Цвет фона: lightGreyColor
