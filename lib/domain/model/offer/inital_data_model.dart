import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';

class InitialDataResponse {
  final String status;
  final List<CategoryModel> categories;
  final List<MerchantModel> merchants;
  final List<Offer> topOffers;
  final List<Offer> offers;
  final OptionsModel options;

  InitialDataResponse({
    required this.status,
    required this.categories,
    required this.merchants,
    required this.topOffers,
    required this.offers,
    required this.options,
  });

  factory InitialDataResponse.fromJson(Map<String, dynamic> json) {
    return InitialDataResponse(
      status: json['status'] as String,
      categories: (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
      merchants: (json['merchants'] as List)
          .map((e) => MerchantModel.fromJson(e))
          .toList(),
      topOffers:
          (json['top_offers'] as List).map((e) => Offer.fromJson(e)).toList(),
      offers: (json['offers'] as List).map((e) => Offer.fromJson(e)).toList(),
      options: OptionsModel.fromJson(json['options']),
    );
  }
}

class MerchantModel {
  final String hash;
  final String name;
  final int totalOffers;

  MerchantModel({
    required this.hash,
    required this.name,
    required this.totalOffers,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      hash: json['hash'] as String,
      name: json['name'] as String,
      totalOffers: json['total_offers'] as int,
    );
  }
}

class OptionsModel {
  final int? categoryId;
  final String? merchantId;
  final String sortBy;
  final String? filterFrom;
  final String? filterTo;
  final String? filterType;
  final String? search;
  final int page;
  final int limit;
  final int total;
  final int lastPage;

  OptionsModel({
    this.categoryId,
    this.merchantId,
    required this.sortBy,
    this.filterFrom,
    this.filterTo,
    this.filterType,
    this.search,
    required this.page,
    required this.limit,
    required this.total,
    required this.lastPage,
  });

  factory OptionsModel.fromJson(Map<String, dynamic> json) {
    return OptionsModel(
      categoryId: json['category_id'] as int?,
      merchantId: json['merchant_id'] as String?,
      sortBy: json['sort_by'] as String,
      filterFrom: json['filter_from'] as String?,
      filterTo: json['filter_to'] as String?,
      filterType: json['filter_type'] as String?,
      search: json['search'] as String?,
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      lastPage: json['last_page'] as int,
    );
  }
}
