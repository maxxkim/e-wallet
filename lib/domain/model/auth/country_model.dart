class CountryModel {
  final String code;
  final String name;
  final String currency;
  final String phoneMask;
  final String phonePattern;
  final String phoneExample;
  final String icon;

  CountryModel({
    required this.code,
    required this.name,
    required this.currency,
    required this.phoneMask,
    required this.phonePattern,
    required this.phoneExample,
    required this.icon,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      code: json['code'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      phoneMask: json['phoneMask'] as String,
      phonePattern: json['phonePattern'] as String,
      phoneExample: json['phoneExample'] as String,
      icon: json['icon'] as String,
    );
  }

  String get flagEmoji {
    if (code.length != 2) return '';

    // Convert country code to regional indicator symbols
    final firstLetter =
        String.fromCharCode(code.codeUnitAt(0) - 'A'.codeUnitAt(0) + 0x1F1E6);
    final secondLetter =
        String.fromCharCode(code.codeUnitAt(1) - 'A'.codeUnitAt(0) + 0x1F1E6);

    return firstLetter + secondLetter;
  }
}
