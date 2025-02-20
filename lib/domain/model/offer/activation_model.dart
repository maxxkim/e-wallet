// lib/domain/model/offer/activation_model.dart

class Activation {
  final int id;
  final int offerId;
  final String userId;
  final String merchantId;
  final String userName;
  final String status;
  final String createdAt;
  final String expiryDate;

  Activation({
    required this.id,
    required this.offerId,
    required this.userId,
    required this.merchantId,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.expiryDate,
  });

  factory Activation.fromJson(Map<String, dynamic> json) {
    return Activation(
      id: json['id'] as int,
      offerId: json['offer_id'] as int,
      userId: json['user_id'] as String,
      merchantId: json['merchant_id'] as String,
      userName: json['user_name'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      expiryDate: json['expiry_date'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'offer_id': offerId,
      'user_id': userId,
      'merchant_id': merchantId,
      'user_name': userName,
      'status': status,
      'created_at': createdAt,
      'expiry_date': expiryDate,
    };
  }

  DateTime get createdAtDateTime => DateTime.parse(createdAt);
  DateTime get expiryDateDateTime => DateTime.parse(expiryDate);
}
