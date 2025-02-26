import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';

class GlobalSearchResponse {
  final String status;
  final List<ContactModel>? contacts;
  final List<Map<String, dynamic>>? transactions;
  final List<Offer>? offers;
  final List<CategoryModel>? categories;
  final List<MerchantSearchResult>? merchants;
  final SearchOptions? options;

  GlobalSearchResponse({
    required this.status,
    this.contacts,
    this.transactions,
    this.offers,
    this.categories,
    this.merchants,
    this.options,
  });

  factory GlobalSearchResponse.fromJson(Map<String, dynamic> json) {
    // Add null safety for all lists
    return GlobalSearchResponse(
      status: json['status'] as String? ?? 'error',
      contacts: json['contacts'] != null
          ? (json['contacts'] as List<dynamic>)
              .map((e) => ContactModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      transactions: json['transactions'] != null
          ? (json['transactions'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList()
          : [],
      offers: json['offers'] != null
          ? (json['offers'] as List<dynamic>)
              .map((e) => Offer.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      categories: json['categories'] != null
          ? (json['categories'] as List<dynamic>)
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      merchants: json['merchants'] != null
          ? (json['merchants'] as List<dynamic>)
              .map((e) =>
                  MerchantSearchResult.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      options: json['options'] != null
          ? SearchOptions.fromJson(json['options'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MerchantSearchResult {
  final String hash;
  final String name;

  MerchantSearchResult({
    required this.hash,
    required this.name,
  });

  factory MerchantSearchResult.fromJson(Map<String, dynamic> json) {
    return MerchantSearchResult(
      hash: json['hash'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  MerchantData toMerchantData() {
    return MerchantData(
      hash: hash,
      name: name,
      totalOffers: 0, // Default value to prevent null errors
    );
  }
}

class SearchOptions {
  final String search;
  final int limit;

  SearchOptions({
    required this.search,
    required this.limit,
  });

  factory SearchOptions.fromJson(Map<String, dynamic> json) {
    return SearchOptions(
      search: json['search'] as String? ?? '',
      limit: json['limit'] as int? ?? 5,
    );
  }
}
