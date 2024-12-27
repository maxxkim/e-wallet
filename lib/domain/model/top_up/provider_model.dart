import 'package:zippy/domain/model/top_up/parameter_model.dart';

class Provider {
  final int id;
  final String name;
  final String description;
  final String? logo;
  final String? title;
  final List<Parameter>? parameters;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Provider({
    required this.id,
    required this.name,
    required this.description,
    this.logo,
    this.title,
    this.parameters,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] as int,
      title: json['title'] as String?,
      name: json['name'] as String,
      description: json['description'] as String,
      logo: json['logo'] as String?,
      parameters: (json['parameters'] as List<dynamic>?)
          ?.map((paramMap) => Parameter.fromJson(paramMap))
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
