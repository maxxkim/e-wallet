class Activation {
  final int id;
  final int offerId;
  final String userId;
  final int status;
  final DateTime createdAt;
  final DateTime expiryDate;

  Activation({
    required this.id,
    required this.offerId,
    required this.userId,
    required this.status,
    required this.createdAt,
    required this.expiryDate,
  });

  factory Activation.fromJson(Map<String, dynamic> json) {
    return Activation(
      id: json['id'] as int,
      offerId: json['offer_id'] as int,
      userId: json['user_id'] as String,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'].toString()),
      expiryDate: DateTime.parse(json['expiry_date'].toString()),
    );
  }
}
