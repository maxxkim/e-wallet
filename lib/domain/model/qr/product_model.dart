// lib/domain/model/qr/product_model.dart

class Product {
  final String id;
  final String name;
  final double price;
  final double discount;
  final int quantity;
  final bool inOffer;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.quantity,
    required this.inOffer,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      inOffer: json['in_offer'] == 1,
    );
  }
}
