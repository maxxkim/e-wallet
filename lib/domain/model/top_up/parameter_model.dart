// ./lib/domain/model/top_up/parameter_model.dart
class ParameterDescription {
  final String label;
  final String placeholder;
  final String validation;
  final String error;

  ParameterDescription({
    required this.label,
    required this.placeholder,
    required this.validation,
    required this.error,
  });

  factory ParameterDescription.fromJson(Map<String, dynamic> json) {
    return ParameterDescription(
      label: json['label'] as String,
      placeholder: json['placeholder'] as String,
      validation: json['validation'] as String,
      error: json['error'] as String,
    );
  }
}

class Parameter {
  final String name;
  final String required;
  final String type;
  final String? mask;
  final String? min;
  final String? max;
  final String? pattern; // Made nullable
  final ParameterDescription? description; // Made nullable
  final List<dynamic>? enumValues;

  Parameter({
    required this.name,
    required this.required,
    required this.type,
    this.mask,
    this.min,
    this.max,
    this.pattern,
    this.description,
    this.enumValues,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      name: json['name'] as String,
      required: json['required'] as String,
      type: json['type'] as String,
      min: json['min']?.toString(),
      max: json['max']?.toString(),
      mask: json['mask'] as String?,
      pattern: json['pattern'] as String?,
      description: json['description'] != null
          ? ParameterDescription.fromJson(
              json['description'] as Map<String, dynamic>)
          : null,
      enumValues: (json['enum'] as List<dynamic>?)?.cast<dynamic>(),
    );
  }
}
