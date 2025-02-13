// ./lib/domain/model/contacts/contact_model.dart
class ContactModel {
  final int id;
  final String userId;
  final String contactId;
  final String name;
  final String? nickname;
  final String country;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContactModel({
    required this.id,
    required this.userId,
    required this.contactId,
    required this.name,
    this.nickname,
    required this.country,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      contactId: json['contact_id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      country: json['country'] as String,
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'contact_id': contactId,
      'name': name,
      'nickname': nickname,
      'country': country,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ContactModel copyWith({
    int? id,
    String? userId,
    String? contactId,
    String? name,
    String? nickname,
    String? country,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
