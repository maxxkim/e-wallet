// ./lib/domain/model/contacts/contact_model.dart
class ContactModel {
  final String userId;
  final String contactId;
  final String name;
  final String? nickname;
  final String country;
  final String currency;
  final String createdAt;
  final bool inContacts;

  ContactModel({
    required this.userId,
    required this.contactId,
    required this.name,
    this.nickname,
    required this.country,
    required this.currency,
    required this.createdAt,
    required this.inContacts,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      userId: json['user_id'] as String,
      contactId: json['contact_id'] as String,
      name: json['name'] as String,
      nickname: json['nickname'] as String?,
      country: json['country'] as String,
      currency: json['currency'] as String,
      inContacts: json['in_contacts'] as bool,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'contact_id': contactId,
      'name': name,
      'nickname': nickname,
      'country': country,
      'currency': currency,
      'in_contacts': inContacts,
      'created_at': createdAt,
    };
  }

  ContactModel copyWith({
    String? userId,
    String? contactId,
    String? name,
    String? nickname,
    String? country,
    String? currency,
    bool? inContacts,
    String? createdAt,
  }) {
    return ContactModel(
      userId: userId ?? this.userId,
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      inContacts: inContacts ?? this.inContacts,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
