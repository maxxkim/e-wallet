// lib/data/api/api_categories_response.dart
import 'package:zippy/domain/model/offer/category_model.dart';

class ApiCategoriesResponse {
  final String status;
  final List<CategoryModel> categories;

  ApiCategoriesResponse({
    required this.status,
    required this.categories,
  });

  factory ApiCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return ApiCategoriesResponse(
      status: json['status'] as String,
      categories: (json['categories'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }
}
