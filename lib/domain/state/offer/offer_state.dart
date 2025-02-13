import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';

abstract class OfferState {}

class OfferStateLoading extends OfferState {}

class OfferStateLoaded extends OfferState {
  final List<Offer> offers;
  final String searchQuery;
  final bool isLoadingMore;
  final List<CategoryModel> selectedCategories;
  final List<MerchantData> selectedMerchants;
  final double? minDiscount;
  final double? maxDiscount;
  final String sortDirection;
  final List<String> selectedOfferTypes;

  OfferStateLoaded({
    required this.offers,
    this.searchQuery = '',
    this.isLoadingMore = false,
    this.selectedCategories = const [],
    this.selectedMerchants = const [],
    this.minDiscount,
    this.maxDiscount,
    this.sortDirection = 'desc',
    this.selectedOfferTypes = const [],
  });

  OfferStateLoaded copyWith({
    List<Offer>? offers,
    String? searchQuery,
    bool? isLoadingMore,
    List<CategoryModel>? selectedCategories,
    List<MerchantData>? selectedMerchants,
    double? minDiscount,
    double? maxDiscount,
    String? sortDirection,
    List<String>? selectedOfferTypes,
  }) {
    return OfferStateLoaded(
      offers: offers ?? this.offers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedMerchants: selectedMerchants ?? this.selectedMerchants,
      minDiscount: minDiscount ?? this.minDiscount,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      sortDirection: sortDirection ?? this.sortDirection,
      selectedOfferTypes: selectedOfferTypes ?? this.selectedOfferTypes,
    );
  }
}

class OfferStateError extends OfferState {
  final String errorMessage;
  OfferStateError({required this.errorMessage});
}
