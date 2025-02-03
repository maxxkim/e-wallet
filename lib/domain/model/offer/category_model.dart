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
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as int,
      totalOffers: json['total_offers'] as int,
    );
  }
}
