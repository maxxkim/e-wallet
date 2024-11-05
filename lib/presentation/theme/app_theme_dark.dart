import 'package:flutter/material.dart';

const Color blackColor = Color(0xFF1D1D1B); // Dark background color
const Color aquamarineColor = Color(0xFF52DAC6); // Accent color
const Color bluePurpleColor = Color(0xFF0F0A54); // Primary color
const Color darkGreyColor = Color(0xFF878787); // Grey for borders/text
const Color lightGreyColor = Color(0xFFEFEFEF); // Light grey for hints
const Color midLightAquamarineColor =
    Color(0xFF8BD8CD); // Lighter version of aquamarine
const Color greenColor = Color(0xFF54C099); // Success color
const Color redColor = Color(0xFFDC4949); // Error color
const Color whiteColor = Color(0xFFFFFFFF); // Text color
const Color lightAquamarineColor = Color(0xFFDDEEEB); // Backgrounds
const Color lightRedColor = Color(0xFFEEDDDD); // Light red for errors

final ThemeData appThemeDark = ThemeData(
  primaryColor: bluePurpleColor,
  secondaryHeaderColor: aquamarineColor,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: darkGreyColor, // Dark background
  colorScheme: const ColorScheme.dark(
    primary: bluePurpleColor,
    secondary: aquamarineColor,
    onPrimary: whiteColor, // Text on primary color
    onSecondary: blackColor, // Text on secondary color
    error: redColor,
    scrim: greenColor,
    surface: darkGreyColor,
    onSurface: lightGreyColor,
  ),
  textTheme: const TextTheme(
    titleSmall: TextStyle(
        color: aquamarineColor,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    titleMedium: TextStyle(
        color: whiteColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    titleLarge: TextStyle(
        color: aquamarineColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    bodySmall: TextStyle(
        color: lightGreyColor,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    bodyMedium: TextStyle(
        color: lightGreyColor,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    bodyLarge: TextStyle(
        color: lightGreyColor,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    headlineSmall: TextStyle(
        color: aquamarineColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    headlineMedium: TextStyle(
        color: aquamarineColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    headlineLarge: TextStyle(
        color: whiteColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'RobotoFlex'),
    displaySmall: TextStyle(
        color: blackColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    displayMedium: TextStyle(
        color: blackColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    displayLarge: TextStyle(
        color: lightGreyColor,
        fontSize: 24,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    labelSmall: TextStyle(
        color: lightGreyColor,
        fontSize: 12,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    labelMedium: TextStyle(
        color: lightGreyColor,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    labelLarge: TextStyle(
        color: greenColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    inText: TextStyle(
        color: greenColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
    outText: TextStyle(
        color: redColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'RobotoFlex'),
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
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16.0)),
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
    hintStyle:
        const TextStyle(color: lightGreyColor, fontWeight: FontWeight.w300),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(bluePurpleColor),
      padding:
          WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8.0)),
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
