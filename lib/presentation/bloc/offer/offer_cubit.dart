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
  // Static variables to hold selected data from search
  static MerchantData? selectedMerchantFromSearch;
  static CategoryModel? selectedCategoryFromSearch;

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

    // Initialize the loadOffers but defer it to handle the search filters first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Handle any pending search filters
      final tempMerchant = selectedMerchantFromSearch;
      final tempCategory = selectedCategoryFromSearch;

      // Clear the static variables immediately to avoid any issues
      selectedMerchantFromSearch = null;
      selectedCategoryFromSearch = null;

      // Apply filters if they exist
      if (tempMerchant != null) {
        print('Applying merchant filter from search: ${tempMerchant.name}');
        selectMerchants([tempMerchant]);
      } else if (tempCategory != null) {
        print('Applying category filter from search: ${tempCategory.name}');
        selectCategories([tempCategory]);
      } else {
        // Otherwise just load all offers
        loadOffers();
      }
    });
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
    } else {
      emit(OfferStateLoaded(
        offers: [],
        selectedCategories: categories,
        selectedMerchants: [],
        sortDirection: 'desc',
        selectedOfferTypes: [],
      ));
    }
    await loadOffers(refresh: true);
  }

  void removeCategory(CategoryModel category) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      final newCategories =
          List<CategoryModel>.from(currentState.selectedCategories)
            ..removeWhere((c) => c.id == category.id);
      selectCategories(newCategories);
    }
  }

  void selectMerchants(List<MerchantData> merchants) async {
    print(
        'Select merchants called with: ${merchants.map((m) => m.name).join(", ")}');
    _currentPage = 1;
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      emit(currentState.copyWith(
        selectedMerchants: merchants,
      ));
    } else {
      emit(OfferStateLoaded(
        offers: [],
        selectedMerchants: merchants,
        selectedCategories: [],
        sortDirection: 'desc',
        selectedOfferTypes: [],
      ));
    }
    await loadOffers(refresh: true);
  }

  void removeMerchant(MerchantData merchant) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      final newMerchants =
          List<MerchantData>.from(currentState.selectedMerchants)
            ..removeWhere((m) => m.hash == merchant.hash);
      selectMerchants(newMerchants);
    }
  }

  void applyFilters({
    String? sortDirection,
    double? minDiscount,
    double? maxDiscount,
    List<String>? offerTypes,
  }) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      _currentPage = 1;
      emit(currentState.copyWith(
        sortDirection: sortDirection ?? currentState.sortDirection,
        minDiscount: minDiscount,
        maxDiscount: maxDiscount,
        selectedOfferTypes: offerTypes ?? currentState.selectedOfferTypes,
      ));
      await loadOffers(refresh: true);
    }
  }

  void clearDiscountFilter() async {
    if (state is OfferStateLoaded) {
      applyFilters(minDiscount: null, maxDiscount: null);
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

      final queryParams = {
        'page': _currentPage,
        'limit': _pageSize,
        'search': searchController.text,
        'sort_by': currentState?.sortDirection ?? 'desc',
      };

      // Apply category filters
      if (currentState?.selectedCategories.isNotEmpty ?? false) {
        queryParams['category_id'] = currentState!.selectedCategories
            .map((c) => c.id.toString())
            .join(',');
      }

      // Apply merchant filters
      if (currentState?.selectedMerchants.isNotEmpty ?? false) {
        queryParams['merchant_id'] =
            currentState!.selectedMerchants.map((m) => m.hash).join(',');
      }

      final initialData = await _offerRepository.getInitialData(
        limit: _pageSize,
        topLimit: _currentPage == 1 ? 5 : 0,
      );

      // Debug logging
      print('Loaded ${initialData.offers.length} offers');
      if (currentState?.selectedMerchants.isNotEmpty ?? false) {
        print(
            'Applied merchant filter: ${currentState!.selectedMerchants.map((m) => m.name).join(", ")}');
      }

      List<Offer> filteredOffers = initialData.offers;

      // Apply discount filters
      if (currentState?.minDiscount != null ||
          currentState?.maxDiscount != null) {
        filteredOffers = filteredOffers.where((offer) {
          final discount = double.tryParse(offer.discount) ?? 0;
          final bonus = double.tryParse(offer.bonus) ?? 0;
          final totalDiscount = discount + bonus;
          if (currentState!.minDiscount != null &&
              totalDiscount < currentState.minDiscount!) {
            return false;
          }
          if (currentState.maxDiscount != null &&
              totalDiscount > currentState.maxDiscount!) {
            return false;
          }
          return true;
        }).toList();
      }

      // Apply offer type filters
      if (currentState?.selectedOfferTypes.isNotEmpty ?? false) {
        filteredOffers = filteredOffers.where((offer) {
          return currentState!.selectedOfferTypes
              .contains(offer.type.toLowerCase());
        }).toList();
      }

      if (currentState != null && !refresh) {
        final List<Offer> updatedOffers = [
          ...currentState.offers,
          ...filteredOffers,
        ];
        emit(currentState.copyWith(
          offers: updatedOffers,
          isLoadingMore: false,
        ));
      } else {
        emit(OfferStateLoaded(
          offers: filteredOffers,
          selectedCategories: currentState?.selectedCategories ?? [],
          selectedMerchants: currentState?.selectedMerchants ?? [],
          minDiscount: currentState?.minDiscount,
          maxDiscount: currentState?.maxDiscount,
          sortDirection: currentState?.sortDirection ?? 'desc',
          selectedOfferTypes: currentState?.selectedOfferTypes ?? [],
        ));
      }

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
          return 'Connection timeout occurred';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'An unknown error occurred';
      }
    }
    return error.toString();
  }
}
