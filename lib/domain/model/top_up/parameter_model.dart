class Parameter {
  final String name;
  final bool required;
  final String type;
  final int min;
  final int max;
  final String pattern;

  Parameter({
    required this.name,
    required this.required,
    required this.type,
    required this.min,
    required this.max,
    required this.pattern,
  });
}
