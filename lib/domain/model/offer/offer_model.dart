// ./lib/domain/model/offer/offer_model.dart
class Offer {
  final int id;
  final String merchantId;
  final String merchantName;
  final String hash;
  final int? categoryId; // Make nullable
  final String? categoryName;
  final String country;
  final String currency;
  final double minAmount;
  final int quantity;
  final String title;
  final String description;
  final String image;
  final String? addImage;
  final String type;
  final String productId;
  final String discount;
  final String discountType;
  final String bonus;
  final int bonusType;
  final String link;
  final DateTime dateStart;
  final DateTime dateEnd;
  final bool is_activation;

  Offer({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.hash,
    this.categoryId, // Make optional
    this.categoryName,
    required this.country,
    required this.currency,
    required this.minAmount,
    required this.quantity,
    required this.title,
    required this.description,
    required this.image,
    this.addImage,
    required this.type,
    required this.productId,
    required this.discount,
    required this.discountType,
    required this.bonus,
    required this.bonusType,
    required this.link,
    required this.dateStart,
    required this.dateEnd,
    required this.is_activation,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      hash: json['hash'] as String,
      categoryId: json['category_id'] != null && json['category_id'] != ""
          ? int.tryParse(json['category_id'].toString())
          : null,
      categoryName: json['category_name'] as String?,
      country: json['country'] as String,
      currency: json['currency'] as String,
      minAmount: (json['min_amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      addImage: json['add_image'] as String?,
      type: json['type'] as String,
      productId: json['product_id'] as String,
      discount: json['discount'] as String,
      discountType: json['discount_type'] as String,
      bonus: json['bonus'] as String,
      bonusType: json['bonus_type'] == 'FIXED' ? 0 : 1,
      link: json['link'] as String,
      dateStart: DateTime.parse(json['date_start'] as String),
      is_activation: json['is_activation'] as bool? ?? false,
      dateEnd: DateTime.parse(json['date_end'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          merchantId == other.merchantId &&
          hash == other.hash;

  @override
  int get hashCode => Object.hash(id, merchantId, hash);
}
