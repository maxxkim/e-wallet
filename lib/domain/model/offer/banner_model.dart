import 'package:zippy/domain/model/offer/offer_model.dart';

class OfferBanner {
  final int id;
  final int offerId;
  final String title;
  final String image;
  final int sort;
  final Offer? offer;

  OfferBanner({
    required this.id,
    required this.offerId,
    required this.title,
    required this.image,
    required this.sort,
    this.offer,
  });

  factory OfferBanner.fromJson(Map<String, dynamic> json) {
    return OfferBanner(
      id: json['id'] as int,
      offerId: json['offer_id'] as int,
      title: json['title'] as String,
      image: json['image'] as String,
      sort: json['sort'] as int,
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
    );
  }
}

class BannerResponse {
  final String status;
  final List<OfferBanner> banners;
  final Map<String, dynamic> options;

  BannerResponse({
    required this.status,
    required this.banners,
    required this.options,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    return BannerResponse(
      status: json['status'] as String,
      banners: (json['banners'] as List)
          .map((e) => OfferBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      options: json['options'] as Map<String, dynamic>,
    );
  }
}
