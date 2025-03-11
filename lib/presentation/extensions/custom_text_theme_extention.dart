import 'package:flutter/material.dart';

import 'package:zippy/presentation/theme/app_theme.dart';

// Extension to add the missing inText and outText properties to TextTheme
extension CustomTextThemeExtension on TextTheme {
  // Extension for income text style (green color)
  TextStyle? get inText => labelLarge?.copyWith(
        color: const Color(0xFF54C099), // greenColor
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );

  // Extension for outgoing text style (red color)
  TextStyle? get outText => labelLarge?.copyWith(
        color: const Color(0xFFDC4949), // redColor
        fontSize: 16,
        fontWeight: FontWeight.w600,
      );
}
