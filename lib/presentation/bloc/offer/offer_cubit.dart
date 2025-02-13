// lib/presentation/bloc/offer/offer_cubit.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _offerRepository;
  int _currentPage = 1;
  static const int _pageSize = 15;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  OfferCubit(this._offerRepository) : super(OfferStateLoading()) {
    _init();
  }

  void _init() {
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);
    loadOffers();
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    searchController.dispose();
    _searchDebounce?.cancel();
    return super.close();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (state is OfferStateLoaded) {
        loadOffers(refresh: true);
      }
    });
  }

  void selectCategories(List<CategoryModel> categories) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      _currentPage = 1;
      emit(currentState.copyWith(
        selectedCategories: categories,
      ));
      await loadOffers(refresh: true);
    }
  }

  void removeCategory(CategoryModel category) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      final newCategories =
          List<CategoryModel>.from(currentState.selectedCategories)
            ..removeWhere((c) => c.id == category.id);
      emit(currentState.copyWith(selectedCategories: newCategories));
      await loadOffers(refresh: true);
    }
  }

  void selectMerchants(List<MerchantData> merchants) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      _currentPage = 1;
      emit(currentState.copyWith(
        selectedMerchants: merchants,
      ));
      await loadOffers(refresh: true);
    }
  }

  void removeMerchant(MerchantData merchant) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      final newMerchants =
          List<MerchantData>.from(currentState.selectedMerchants)
            ..removeWhere((m) => m.hash == merchant.hash);
      emit(currentState.copyWith(selectedMerchants: newMerchants));
      await loadOffers(refresh: true);
    }
  }

  void setSortDirection(String direction) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      emit(currentState.copyWith(sortDirection: direction));
      await loadOffers(refresh: true);
    }
  }

  void setSelectedOfferTypes(List<String> types) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      emit(currentState.copyWith(selectedOfferTypes: types));
      await loadOffers(refresh: true);
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (state is OfferStateLoaded &&
          !(state as OfferStateLoaded).isLoadingMore) {
        loadOffers();
      }
    }
  }

  Future<void> loadOffers({bool refresh = false}) async {
    try {
      final currentState =
          state is OfferStateLoaded ? state as OfferStateLoaded : null;

      if (refresh) {
        _currentPage = 1;
        emit(OfferStateLoading());
      } else if (currentState != null) {
        emit(currentState.copyWith(isLoadingMore: true));
      }

      // Load initial data with pagination
      final initialData = await _offerRepository.getInitialData(
        limit: _pageSize,
        topLimit:
            _currentPage == 1 ? 5 : 0, // Only load top offers on first page
      );

      if (currentState != null && !refresh) {
        // For pagination: combine existing and new offers
        final List<Offer> updatedOffers = [
          ...currentState.offers,
          ...initialData.offers,
        ];

        emit(currentState.copyWith(
          offers: updatedOffers,
          isLoadingMore: false,
        ));
      } else {
        // First load or refresh
        emit(OfferStateLoaded(
          offers: initialData.offers,
          selectedCategories: initialData.categories,
          selectedMerchants: initialData.merchants
              .map((m) => MerchantData(
                    hash: m.hash,
                    name: m.name,
                    totalOffers: m.totalOffers,
                  ))
              .toList(),
          minDiscount: null,
          maxDiscount: null,
          sortDirection: initialData.options.sortBy,
          selectedOfferTypes: [],
        ));
      }

      // Check if we should load more based on total pages
      if (_currentPage < initialData.options.lastPage) {
        _currentPage++;
      }
    } catch (e) {
      if (state is OfferStateLoaded) {
        final currentState = state as OfferStateLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      }
      emit(OfferStateError(errorMessage: _handleError(e)));
    }
  }

  void setDiscountRange(double? min, double? max) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      _currentPage = 1;
      emit(currentState.copyWith(
        minDiscount: min,
        maxDiscount: max,
      ));
      await loadOffers(refresh: true);
    }
  }

  void clearDiscountFilter() async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      emit(currentState.copyWith(
        minDiscount: null,
        maxDiscount: null,
      ));
      await loadOffers(refresh: true);
    }
  }

  Future<void> refresh() async {
    _currentPage = 1;
    await loadOffers(refresh: true);
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['status'] == 'error' &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout occurred UwU';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded >w<';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded nyaa~';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled OwO';
        default:
          return 'An unknown error occurred >.<';
      }
    }
    return error.toString();
  }
}
