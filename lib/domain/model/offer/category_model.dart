class CategoryModel {
  final int id;
  final String name;
  final int sort;
  final int totalOffers;

  CategoryModel({
    required this.id,
    required this.name,
    required this.sort,
    required this.totalOffers,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // Add null checks and default values
    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      sort: json['sort'] as int? ?? 0,
      totalOffers: json['total_offers'] as int? ?? 0, // Default to 0 if null
    );
  }
}
