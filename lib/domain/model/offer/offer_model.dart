// lib/domain/model/offer/offer_model.dart

class Offer {
  final int id;
  final String merchantId;
  final String merchantName;
  final String hash;
  final int categoryId;
  final String? categoryName; // Made nullable
  final String country;
  final String currency;
  final double minAmount;
  final int quantity;
  final String title;
  final String description;
  final String image;
  final String? addImage; // Made nullable
  final int type;
  final String productId;
  final String discount;
  final int discountType;
  final String bonus;
  final int bonusType;
  final String link;
  final DateTime dateStart;
  final DateTime dateEnd;

  Offer({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.hash,
    required this.categoryId,
    this.categoryName, // Optional
    required this.country,
    required this.currency,
    required this.minAmount,
    required this.quantity,
    required this.title,
    required this.description,
    required this.image,
    this.addImage, // Optional
    required this.type,
    required this.productId,
    required this.discount,
    required this.discountType,
    required this.bonus,
    required this.bonusType,
    required this.link,
    required this.dateStart,
    required this.dateEnd,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      hash: json['hash'] as String,
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String?, // Handle null
      country: json['country'] as String,
      currency: json['currency'] as String,
      minAmount: (json['min_amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      addImage: json['add_image'] as String?, // Handle null
      type: json['type'] as int,
      productId: json['product_id'] as String,
      discount: json['discount'] as String,
      discountType: json['discount_type'] as int,
      bonus: json['bonus'] as String,
      bonusType: json['bonus_type'] as int,
      link: json['link'] as String,
      dateStart: DateTime.parse(json['date_start'] as String),
      dateEnd: DateTime.parse(json['date_end'] as String),
    );
  }
}
