// lib/presentation/bloc/offer/offer_cubit.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _offerRepository;
  int _currentPage = 1;
  static const int _pageSize = 20;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController =
      TextEditingController(); // Added this
  Timer? _searchDebounce; // Add this for search debouncing

  OfferCubit(this._offerRepository) : super(OfferStateLoading()) {
    _init();
  }

  void _init() {
    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchChanged); // Add search listener
    loadOffers();
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    searchController.dispose(); // Dispose search controller
    _searchDebounce?.cancel(); // Cancel timer if exists
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

  void selectFilter(FilterType type) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;
      if (currentState.filterType == type) return;

      _currentPage = 1;
      emit(currentState.copyWith(filterType: type));

      await loadOffers(refresh: true);
    }
  }

  void selectCategory(CategoryModel? category) async {
    if (state is OfferStateLoaded) {
      final currentState = state as OfferStateLoaded;

      _currentPage = 1;
      emit(currentState.copyWith(
        selectedCategory: category,
        filterType: FilterType.category,
      ));

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

      List<Offer> offers;
      if (currentState?.filterType == FilterType.top) {
        offers = await _offerRepository.getTopOffers();
      } else {
        offers = await _offerRepository.getOffers(
          page: _currentPage,
          limit: _pageSize,
          categoryId: currentState?.selectedCategory?.id,
        );
      }

      if (currentState != null && !refresh) {
        emit(currentState.copyWith(
          offers: [...currentState.offers, ...offers],
          isLoadingMore: false,
        ));
      } else {
        emit(OfferStateLoaded(
          offers: offers,
          filterType: currentState?.filterType ?? FilterType.all,
          selectedCategory: currentState?.selectedCategory,
        ));
      }
      _currentPage++;
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
