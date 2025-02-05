import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';

enum FilterType { all, category, top }

abstract class OfferState {}

class OfferStateLoading extends OfferState {}

class OfferStateLoaded extends OfferState {
  final List<Offer> offers;
  final String searchQuery;
  final bool isLoadingMore;
  final List<CategoryModel> selectedCategories;
  final FilterType filterType;

  OfferStateLoaded({
    required this.offers,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.selectedCategories = const [],
    this.filterType = FilterType.all,
  });

  OfferStateLoaded copyWith({
    List<Offer>? offers,
    String? searchQuery,
    bool? isLoadingMore,
    List<CategoryModel>? selectedCategories,
    FilterType? filterType,
  }) {
    return OfferStateLoaded(
      offers: offers ?? this.offers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      filterType: filterType ?? this.filterType,
    );
  }
}

class OfferStateError extends OfferState {
  final String errorMessage;

  OfferStateError({required this.errorMessage});
}
