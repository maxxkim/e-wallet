import 'package:flutter/material.dart';

const Color blackColor = Color(0xFF1D1D1B);
const Color aquamarineColor = Color(0xFF52DAC6);
const Color bluePurpleColor = Color(0xFF0F0A54);
const Color darkGreyColor = Color(0xFF878787);
const Color lightGreyColor = Color(0xFFEFEFEF);
const Color lightAquamarineColor = Color(0xFFDDEEEB);
const Color midLightAquamarineColor = Color(0xFF8BD8CD);
const Color greenColor = Color(0xFF54C099);
const Color redColor = Color(0xFFDC4949);
const Color lightRedColor = Color(0xFFEEDDDD);
const Color whiteColor = Color(0xFFFFFFFF);
const Color lightYellowColor = Color(0xFFFFF7E3);
const Color yellowColor = Color(0xFFFFAB6D);

final ThemeData appTheme = ThemeData(
  primaryColor: bluePurpleColor,
  secondaryHeaderColor: aquamarineColor,
  brightness: Brightness.light,
  scaffoldBackgroundColor: whiteColor,

  colorScheme: const ColorScheme.light(
    primary: bluePurpleColor,
    secondary: aquamarineColor,
    secondaryFixed: midLightAquamarineColor, // Установка аквамаринового цвета как вторичного
    secondaryContainer: lightAquamarineColor, 
    tertiary: whiteColor,
    tertiaryContainer: lightGreyColor,
    tertiaryFixed: lightRedColor,
    error: redColor,
    scrim: greenColor,
  ), 

  textTheme: const TextTheme(
    titleSmall: TextStyle(color: bluePurpleColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    titleMedium: TextStyle(color: bluePurpleColor, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'RobotoFlex'),
    titleLarge: TextStyle(color: bluePurpleColor, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    bodySmall: TextStyle(color: blackColor, fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'RobotoFlex'),
    bodyMedium: TextStyle(color: blackColor, fontSize: 14, fontWeight: FontWeight.w400, fontFamily: 'RobotoFlex'), 
    bodyLarge: TextStyle(color: blackColor, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'RobotoFlex'),
    headlineSmall: TextStyle(color: bluePurpleColor, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'RobotoFlex'), 
    headlineMedium: TextStyle(color: bluePurpleColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    displaySmall: TextStyle(color: whiteColor, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    displayMedium: TextStyle(color: whiteColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    labelSmall: TextStyle(color: lightGreyColor, fontSize: 12, fontWeight: FontWeight.w300, fontFamily: 'RobotoFlex'),
    labelMedium: TextStyle(color: lightGreyColor, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'RobotoFlex'),
    labelLarge: TextStyle(color: greenColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    inText: TextStyle(color: greenColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
    outText: TextStyle(color: redColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'RobotoFlex'),
  ),

  appBarTheme: const AppBarTheme(
    toolbarHeight: 0,
    color: whiteColor,
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
