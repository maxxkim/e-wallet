import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/initial_data_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';

class OfferCubit extends Cubit<OfferState> {
  static MerchantData? selectedMerchantFromSearch;
  static CategoryModel? selectedCategoryFromSearch;
  final OfferRepository _offerRepository;
  int _currentPage = 1;
  static const int _pageSize = 15;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  // Track loading state
  bool _isLoadingMore = false;

  // Store the last received data to check pagination info
  InitialDataResponse? _initialData;
  void _logEvent(String message) {
    LoggerService().debug('🎁 OFFER SCREEN: $message');
  }

  OfferCubit(this._offerRepository) : super(OfferStateLoading()) {
    _init();
  }

  void _init() {
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tempMerchant = selectedMerchantFromSearch;
      final tempCategory = selectedCategoryFromSearch;

      selectedMerchantFromSearch = null;
      selectedCategoryFromSearch = null;

      if (tempMerchant != null) {
        _logEvent('Applying merchant filter from search: ${tempMerchant.name}');
        selectMerchants([tempMerchant]);
      } else if (tempCategory != null) {
        _logEvent('Applying category filter from search: ${tempCategory.name}');
        selectCategories([tempCategory]);
      } else {
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
    _logEvent(
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
    // Only try to load more if we're near the bottom and not already loading
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (state is OfferStateLoaded &&
          !(state as OfferStateLoaded).isLoadingMore &&
          !_isLoadingMore) {
        // Only try to load more if we're not already on the last page
        if (_currentPage <= (_initialData?.options.lastPage ?? 1)) {
          loadOffers();
        } else {
          _logEvent('Already on last page, not loading more');
        }
      }
    }
  }

  Future<void> loadOffers({bool refresh = false}) async {
    try {
      // If already loading more, prevent additional requests
      if (_isLoadingMore && !refresh) return;
      _isLoadingMore = true;

      final currentState =
          state is OfferStateLoaded ? state as OfferStateLoaded : null;
      if (refresh) {
        _currentPage = 1;
        emit(OfferStateLoading());
      } else if (currentState != null) {
        // Only emit loading more if we're not on the last page
        if (_currentPage <= (_initialData?.options.lastPage ?? 1)) {
          emit(currentState.copyWith(isLoadingMore: true));
        } else {
          _isLoadingMore = false;
          return; // Don't load more if we're already on the last page
        }
      }

      _logEvent('📱 Fetching offers page $_currentPage');

      // Pass the page parameter to the repository call
      final initialData = await _offerRepository.getInitialData(
        limit: _pageSize,
        topLimit: _currentPage == 1 ? 5 : 0,
        page: _currentPage,
      );

      _logEvent(
          'Loaded ${initialData.offers.length} offers for page $_currentPage');
      _logEvent(
          'Last page is: ${initialData.options.lastPage}, Total offers: ${initialData.options.total}');

      // Store the last received data to check pagination info
      _initialData = initialData;

      List<Offer> filteredOffers = initialData.offers;

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

      if (currentState?.selectedOfferTypes.isNotEmpty ?? false) {
        filteredOffers = filteredOffers.where((offer) {
          return currentState!.selectedOfferTypes
              .contains(offer.type.toLowerCase());
        }).toList();
      }

      // Check for duplicates when appending data
      if (currentState != null && !refresh) {
        // Create a set of existing offer IDs to prevent duplicates
        final existingOfferIds = currentState.offers.map((o) => o.id).toSet();

        // Only add new offers that aren't already in the list
        final newOffers = filteredOffers
            .where((offer) => !existingOfferIds.contains(offer.id))
            .toList();

        if (newOffers.isEmpty) {
          _logEvent(
              '⚠️ No new offers found on page $_currentPage, stopping pagination');
          emit(currentState.copyWith(isLoadingMore: false));
        } else {
          _logEvent(
              '✅ Adding ${newOffers.length} new offers from page $_currentPage');
          final List<Offer> updatedOffers = [
            ...currentState.offers,
            ...newOffers,
          ];
          emit(currentState.copyWith(
            offers: updatedOffers,
            isLoadingMore: false,
          ));
        }
      } else {
        emit(OfferStateLoaded(
          offers: filteredOffers,
          selectedCategories: currentState?.selectedCategories ?? [],
          selectedMerchants: currentState?.selectedMerchants ?? [],
          minDiscount: currentState?.minDiscount,
          maxDiscount: currentState?.maxDiscount,
          sortDirection: currentState?.sortDirection ?? 'desc',
          selectedOfferTypes: currentState?.selectedOfferTypes ?? [],
          isLoadingMore: false,
        ));
      }

      // Only increment page if we got data and haven't reached the last page
      // AND if the page we just loaded has the expected number of items
      if (filteredOffers.isNotEmpty &&
          _currentPage < initialData.options.lastPage &&
          filteredOffers.length >= _pageSize) {
        _currentPage++;
        _logEvent('⏭️ Next page will be: $_currentPage');
      } else {
        _logEvent(
            '🛑 Reached last page or incomplete page. Not incrementing page counter.');
      }
    } catch (e) {
      _logEvent('❌ Error loading offers: ${e.toString()}');
      if (state is OfferStateLoaded) {
        final currentState = state as OfferStateLoaded;
        emit(currentState.copyWith(isLoadingMore: false));
      } else {
        emit(OfferStateError(errorMessage: _handleError(e)));
      }
    } finally {
      _isLoadingMore = false;
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
