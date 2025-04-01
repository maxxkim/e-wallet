import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/screen/topUp/helpers/thousand_separator_formatter.dart';

class ParameterMaskFormatter {
  /// Creates and returns appropriate TextInputFormatter based on parameter type and mask
  static TextInputFormatter? getFormatter(Parameter parameter) {
    // If no mask is provided, try to create one based on pattern
    String mask = parameter.mask ?? '';
    if (parameter.mask == null || parameter.mask!.isEmpty) {
      return _createFormatterFromPattern(parameter);
    }

    LoggerService().debug("$mask");
    // Handle different mask patterns
    if (mask.contains('\$')) {
      // Create a custom formatter that applies the mask from the end
      return ThousandSeparatorFormatter(mask);
    }
    if (mask.contains('#')) {
      LoggerService().debug("$mask");
      Map<String, RegExp> filter = {"#": RegExp(r'[0-9]')};

      // Handle special characters in Chilean RUT format
      if (mask.contains('-') && mask.contains('.')) {
        filter["X"] = RegExp(r'[0-9kK]');
      }

      return MaskTextInputFormatter(
        mask: mask,
        filter: filter,
      );
    } else if (mask.contains('*')) {
      // Email or free text masks
      return null; // No specific formatter for these types
    } else if (mask.startsWith('+')) {
      // Phone number masks
      return MaskTextInputFormatter(
        mask: mask,
        filter: {"#": RegExp(r'[0-9]')},
      );
    }

    return null;
  }

  /// Create formatter based on pattern when no mask is provided
  static TextInputFormatter? _createFormatterFromPattern(Parameter parameter) {
    if (parameter.type.toLowerCase() == 'email') {
      return null; // No formatter for email
    }

    if (parameter.pattern != null) {
      // Amount fields with specific numeric patterns
      if (parameter.pattern!.contains(r'\d') ||
          parameter.name.toLowerCase() == 'amount') {
        return FilteringTextInputFormatter.digitsOnly;
      }

      // RUT/Document ID patterns for Chilean format
      if (parameter.pattern!.contains(r'-[0-9K]') ||
          parameter.name.toLowerCase().contains('document')) {
        return MaskTextInputFormatter(
          mask: "##.###.###-X",
          filter: {"#": RegExp(r'[0-9]'), "X": RegExp(r'[0-9kK]')},
        );
      }

      // Phone number patterns
      if (parameter.pattern!.contains(r'\+')) {
        return MaskTextInputFormatter(
          mask: "+# (###) ### ## ##",
          filter: {"#": RegExp(r'[0-9]')},
        );
      }
    }

    return null;
  }

  /// Returns appropriate hint text based on parameter definition
  static String? getHint(Parameter parameter) {
    // First priority: use the placeholder from description
    if (parameter.description?.placeholder != null) {
      return parameter.description!.placeholder;
    }

    // Second priority: use the mask if available
    if (parameter.mask != null && parameter.mask!.isNotEmpty) {
      return parameter.mask;
    }

    // Third priority: create hint based on parameter type/name
    if (parameter.type.toLowerCase() == 'email') {
      return "example@email.com";
    } else if (parameter.name.toLowerCase().contains('amount')) {
      return "10000";
    } else if (parameter.name.toLowerCase().contains('document')) {
      return "12.345.678-9";
    } else if (parameter.name.toLowerCase().contains('phone')) {
      return "+56 (912) 345 678";
    }

    return null;
  }

  /// Validates input value against parameter constraints
  static String? validateValue(String? value, Parameter parameter) {
    if (value == null || value.isEmpty) {
      if (parameter.required == "true") {
        return parameter.description?.error ?? "Este campo es obligatorio";
      }
      return null;
    }

    // Length validation
    if (parameter.min != null && value.length < int.parse(parameter.min!)) {
      return parameter.description?.error ?? "El valor es demasiado corto";
    }

    if (parameter.max != null && value.length > int.parse(parameter.max!)) {
      return parameter.description?.error ?? "El valor es demasiado largo";
    }

    // Pattern validation
    if (parameter.pattern != null && parameter.pattern!.isNotEmpty) {
      final RegExp regex = RegExp(parameter.pattern!);
      if (!regex.hasMatch(value)) {
        return parameter.description?.error ?? "Formato inválido";
      }
    }

    // Type specific validation
    if (parameter.type.toLowerCase() == 'email') {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(value)) {
        return parameter.description?.error ?? "Correo electrónico inválido";
      }
    }

    return null;
  }

  /// Format value according to mask (useful for display)
  static String formatValue(String value, Parameter parameter) {
    final formatter = getFormatter(parameter);
    if (formatter is MaskTextInputFormatter) {
      return formatter.maskText(value);
    }
    return value;
  }
}
