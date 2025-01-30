// lib/domain/state/offer/offer_state.dart

import 'package:zippy/domain/model/offer/offer_model.dart';

abstract class OfferState {}

class OfferStateLoading extends OfferState {}

class OfferStateLoaded extends OfferState {
  final List<Offer> offers;
  final String searchQuery;
  final bool isLoadingMore;

  OfferStateLoaded({
    required this.offers,
    this.searchQuery = '',
    this.isLoadingMore = false,
  });

  OfferStateLoaded copyWith({
    List<Offer>? offers,
    String? searchQuery,
    bool? isLoadingMore,
  }) {
    return OfferStateLoaded(
      offers: offers ?? this.offers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class OfferStateError extends OfferState {
  final String errorMessage;

  OfferStateError({required this.errorMessage});
}
