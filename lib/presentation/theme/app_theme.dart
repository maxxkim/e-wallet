import 'package:flutter/material.dart';

const Color bluePurpleColor = Color(0xFF0F0A54);
// Gradient colors for darkBlueGradient
const Color darkBlueGradientStartColor = Color(0xFF0b3eb4);
const Color darkBlueGradientEndColor = Color(0xFF0B3597);
// Gradient colors for deepBlueGradient
const Color aquaBlueColor = Color(0xFF7BE7D7);
const Color deepBlueColor = Color(0xFF1258FD);
const Color darkGreyColor = Color(0xFF878787);
const Color lightGreyColor = Color(0xFFF8F8F8);
const Color lightAquamarineColor = Color(0xFFDDEEEB);
const Color midLightAquamarineColor = Color(0xFF8BD8CD);
const Color greenColor = Color(0xFF54C099);
const Color redColor = Color(0xFFDC4949);
const Color lightRedColor = Color(0xFFEEDDDD);
const Color whiteColor = Color(0xFFFFFFFF);
const Color lightYellowColor = Color(0xFFFFF7E3);
const Color yellowColor = Color(0xFFFFAB6D);

// Define the gradients UwU
const LinearGradient darkBlueGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    darkBlueGradientStartColor,
    darkBlueGradientEndColor,
  ],
);

// Pretty new gradient with multiple color stops ✨
const LinearGradient deepBlueGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    aquaBlueColor,
    deepBlueColor,
  ],
);

final ThemeData appTheme = ThemeData(
  primaryColor: bluePurpleColor,
  secondaryHeaderColor: bluePurpleColor,
  brightness: Brightness.light,
  scaffoldBackgroundColor: whiteColor,
  colorScheme: const ColorScheme.light(
    primary: bluePurpleColor,
    secondary: deepBlueColor,
    secondaryFixed: midLightAquamarineColor,
    secondaryContainer: lightAquamarineColor,
    tertiary: whiteColor,
    tertiaryContainer: lightGreyColor,
    tertiaryFixed: lightRedColor,
    error: redColor,
    scrim: greenColor,
    onErrorContainer: lightRedColor,
    onTertiaryContainer: lightYellowColor,
    surface: darkBlueGradientStartColor,
  ),
  extensions: const [
    ThemeGradients(
      darkBlueGradient: darkBlueGradient,
      deepBlueGradient: deepBlueGradient,
    ),
  ],
  textTheme: const TextTheme(
    titleSmall: TextStyle(
        color: bluePurpleColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    titleMedium: TextStyle(
        color: bluePurpleColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    titleLarge: TextStyle(
        color: bluePurpleColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    bodySmall: TextStyle(
        color: deepBlueColor,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    bodyMedium: TextStyle(
        color: bluePurpleColor,
        fontSize: 14,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    bodyLarge: TextStyle(
        color: bluePurpleColor,
        fontSize: 16,
        fontWeight: FontWeight.w300,
        fontFamily: 'RobotoFlex'),
    headlineSmall: TextStyle(
        color: bluePurpleColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    headlineMedium: TextStyle(
        color: bluePurpleColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    headlineLarge: TextStyle(
        color: bluePurpleColor,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        fontFamily: 'RobotoFlex'),
    displaySmall: TextStyle(
        color: whiteColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    displayMedium: TextStyle(
        color: whiteColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    displayLarge: TextStyle(
        color: bluePurpleColor,
        fontSize: 20,
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
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    inText: TextStyle(
        color: greenColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
    outText: TextStyle(
        color: redColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'RobotoFlex'),
  ),
  appBarTheme: const AppBarTheme(
    toolbarHeight: 0,
    color: whiteColor,
    foregroundColor: whiteColor,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: lightGreyColor, // kawaii background color! (｡♥‿♥｡)
    contentTextStyle: const TextStyle(
        color: darkGreyColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'RobotoFlex'),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16), // Make it round nya~
    ),
    behavior: SnackBarBehavior.floating, // Floating snackbars are so cute! >w
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
          fontWeight: FontWeight.w600,
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
          fontWeight: FontWeight.w600,
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

class ThemeGradients extends ThemeExtension<ThemeGradients> {
  final LinearGradient darkBlueGradient;
  final LinearGradient deepBlueGradient;

  const ThemeGradients({
    required this.darkBlueGradient,
    required this.deepBlueGradient,
  });

  @override
  ThemeExtension<ThemeGradients> copyWith({
    LinearGradient? darkBlueGradient,
    LinearGradient? deepBlueGradient,
  }) {
    return ThemeGradients(
      darkBlueGradient: darkBlueGradient ?? this.darkBlueGradient,
      deepBlueGradient: deepBlueGradient ?? this.deepBlueGradient,
    );
  }

  @override
  ThemeExtension<ThemeGradients> lerp(
    covariant ThemeExtension<ThemeGradients>? other,
    double t,
  ) {
    if (other is! ThemeGradients) {
      return this;
    }
    return ThemeGradients(
      darkBlueGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
              darkBlueGradient.colors[0], other.darkBlueGradient.colors[0], t)!,
          Color.lerp(
              darkBlueGradient.colors[1], other.darkBlueGradient.colors[1], t)!,
        ],
      ),
      deepBlueGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.lerp(
              deepBlueGradient.colors[0], other.deepBlueGradient.colors[0], t)!,
          Color.lerp(
              deepBlueGradient.colors[1], other.deepBlueGradient.colors[1], t)!,
          Color.lerp(
              deepBlueGradient.colors[2], other.deepBlueGradient.colors[2], t)!,
          Color.lerp(
              deepBlueGradient.colors[3], other.deepBlueGradient.colors[3], t)!,
        ],
        stops: deepBlueGradient.stops,
      ),
    );
  }
}
