import 'package:flutter/services.dart';

class ThousandSeparatorFormatter extends TextInputFormatter {
  final String mask;

  ThousandSeparatorFormatter(this.mask);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove any non-numeric characters from the input
    String numericOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Format with thousand separators
    String formatted = _formatWithThousandSeparator(numericOnly);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatWithThousandSeparator(String value) {
    // Handle empty values
    if (value.isEmpty) return '';

    // Extract the separator from the mask ($ or any other character)
    String separator =
        mask.contains('\$') ? '.' : mask.replaceAll('#', '').trim();

    // Format the number with thousand separators
    final result = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        result.write(separator);
      }
      result.write(value[i]);
    }

    return result.toString();
  }
}
