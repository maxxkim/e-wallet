// lib/presentation/bloc/offer/offer_cubit.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';

class OfferCubit extends Cubit<OfferState> {
  final OfferRepository _offerRepository;
  int _currentPage = 1;
  static const int _pageSize = 20;
  Timer? _searchDebounce;
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

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
    _searchDebounce?.cancel();
    scrollController.dispose();
    searchController.dispose();
    return super.close();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchOffers(searchController.text);
    });
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
      if (refresh) {
        _currentPage = 1;
        emit(OfferStateLoading());
      } else if (state is OfferStateLoaded) {
        emit((state as OfferStateLoaded).copyWith(isLoadingMore: true));
      }

      final offers = await _offerRepository.getOffers(
        page: _currentPage,
        limit: _pageSize,
        search: searchController.text,
      );

      if (state is OfferStateLoaded && !refresh) {
        final currentState = state as OfferStateLoaded;
        emit(OfferStateLoaded(
          offers: [...currentState.offers, ...offers],
          searchQuery: searchController.text,
          isLoadingMore: false,
        ));
      } else {
        emit(OfferStateLoaded(
          offers: offers,
          searchQuery: searchController.text,
          isLoadingMore: false,
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

  Future<void> searchOffers(String query) async {
    try {
      _currentPage = 1;
      emit(OfferStateLoading());

      final offers = await _offerRepository.getOffers(
        page: _currentPage,
        limit: _pageSize,
        search: query,
      );

      emit(OfferStateLoaded(
        offers: offers,
        searchQuery: query,
        isLoadingMore: false,
      ));
      _currentPage++;
    } catch (e) {
      emit(OfferStateError(errorMessage: _handleError(e)));
    }
  }

  Future<void> refresh() async {
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
