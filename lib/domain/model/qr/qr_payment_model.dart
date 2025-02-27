// In lib/domain/model/qr/qr_payment_model.dart

class QrMerchant {
  final String name;
  final String url;

  QrMerchant({
    required this.name,
    required this.url,
  });

  factory QrMerchant.fromJson(Map<String, dynamic> json) {
    return QrMerchant(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}

class QrCode {
  final String hash;
  final String currency;
  final double amount;
  final String? outPaymentId;
  final String type;
  final String status;
  final int isTemporary;
  final String? successUrl;
  final String? failUrl;

  QrCode({
    required this.hash,
    required this.currency,
    required this.amount,
    this.outPaymentId,
    required this.type,
    required this.status,
    required this.isTemporary,
    this.successUrl,
    this.failUrl,
  });

  factory QrCode.fromJson(Map<String, dynamic> json) {
    return QrCode(
      hash: json['hash'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      outPaymentId: json['out_payment_id'] as String?,
      type: json['type'] as String,
      status: json['status'] as String,
      isTemporary: json['is_temporary'] as int,
      successUrl: json['success_url'] as String?,
      failUrl: json['fail_url'] as String?,
    );
  }
}

class QrOffer {
  final int id;
  final String merchantId;
  final String merchantName;
  final String hash;
  final int? categoryId;
  final String? categoryName;
  final String country;
  final String currency;
  final double minAmount;
  final int quantity;
  final int activationsCount;
  final String title;
  final String description;
  final String image;
  final String? addImage;
  final String type;
  final String productId;
  final String discount;
  final String discountType;
  final String bonus;
  final String bonusType;
  final int bonusUnlockDays;
  final String link;
  final String dateStart;
  final String dateEnd;

  QrOffer({
    required this.id,
    required this.merchantId,
    required this.merchantName,
    required this.hash,
    this.categoryId,
    this.categoryName,
    required this.country,
    required this.currency,
    required this.minAmount,
    required this.quantity,
    required this.activationsCount,
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
    required this.bonusUnlockDays,
    required this.link,
    required this.dateStart,
    required this.dateEnd,
  });

  factory QrOffer.fromJson(Map<String, dynamic> json) {
    return QrOffer(
      id: json['id'] as int,
      merchantId: json['merchant_id'] as String,
      merchantName: json['merchant_name'] as String,
      hash: json['hash'] as String,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      country: json['country'] as String,
      currency: json['currency'] as String,
      minAmount: (json['min_amount'] as num).toDouble(),
      quantity: json['quantity'] as int,
      activationsCount: json['activations_count'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      addImage: json['add_image'] as String?,
      type: json['type'] as String,
      productId: json['product_id'] as String,
      discount: json['discount'] as String,
      discountType: json['discount_type'] as String,
      bonus: json['bonus'] as String,
      bonusType: json['bonus_type'] as String,
      bonusUnlockDays: json['bonus_unlock_days'] as int,
      link: json['link'] as String,
      dateStart: json['date_start'] as String,
      dateEnd: json['date_end'] as String,
    );
  }
}

class QrActivation {
  final int id;
  final int offerId;
  final String userId;
  final String merchantId;
  final String userName;
  final String status;
  final String createdAt;
  final String expiryDate;

  QrActivation({
    required this.id,
    required this.offerId,
    required this.userId,
    required this.merchantId,
    required this.userName,
    required this.status,
    required this.createdAt,
    required this.expiryDate,
  });

  factory QrActivation.fromJson(Map<String, dynamic> json) {
    return QrActivation(
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
}

// Update the QrPaymentResponse class to include offer and activation
class QrPaymentResponse {
  final String status;
  final QrCode qrCode;
  final QrMerchant merchant;
  final QrOffer? offer;
  final QrActivation? activation;

  QrPaymentResponse({
    required this.status,
    required this.qrCode,
    required this.merchant,
    this.offer,
    this.activation,
  });

  factory QrPaymentResponse.fromJson(Map<String, dynamic> json) {
    return QrPaymentResponse(
      status: json['status'] as String,
      qrCode: QrCode.fromJson(json['qr_code'] as Map<String, dynamic>),
      merchant: QrMerchant.fromJson(json['merchant'] as Map<String, dynamic>),
      offer: json['offer'] != null
          ? QrOffer.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
      activation: json['activation'] != null
          ? QrActivation.fromJson(json['activation'] as Map<String, dynamic>)
          : null,
    );
  }

  // Helper method to calculate discount or bonus if applicable
  double calculateDiscount(double originalAmount) {
    if (offer == null || activation == null) {
      return 0.0;
    }

    double discountValue = 0.0;

    // Use discount if greater than 0, otherwise use bonus
    if (double.parse(offer!.discount) > 0) {
      final discountAmount = double.parse(offer!.discount);
      if (offer!.discountType == 'PERCENTAGE') {
        discountValue = originalAmount * (discountAmount / 100);
      } else {
        // FIXED
        discountValue = discountAmount;
      }
    } else if (double.parse(offer!.bonus) > 0) {
      final bonusAmount = double.parse(offer!.bonus);
      if (offer!.bonusType == 'PERCENTAGE') {
        discountValue = originalAmount * (bonusAmount / 100);
      } else {
        // FIXED
        discountValue = bonusAmount;
      }
    }

    return discountValue;
  }
}
