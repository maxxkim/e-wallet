// lib/data/api/api_global_search_response.dart
import 'package:zippy/domain/model/search/global_search_model.dart';

class ApiGlobalSearchResponse {
  final String status;
  final List<dynamic> contacts;
  final List<dynamic> transactions;
  final List<dynamic> offers;
  final List<dynamic> categories;
  final List<dynamic> merchants;
  final Map<String, dynamic> options;

  ApiGlobalSearchResponse.fromApi(Map<String, dynamic> json)
      : status = json['status'],
        contacts = json['contacts'] ?? [],
        transactions = json['transactions'] ?? [],
        offers = json['offers'] ?? [],
        categories = json['categories'] ?? [],
        merchants = json['merchants'] ?? [],
        options = json['options'] ?? {};

  GlobalSearchResponse toDomain() {
    return GlobalSearchResponse.fromJson({
      'status': status,
      'contacts': contacts,
      'transactions': transactions,
      'offers': offers,
      'categories': categories,
      'merchants': merchants,
      'options': options,
    });
  }
}
