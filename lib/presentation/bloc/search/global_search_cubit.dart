import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/search/global_search_model.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';
import 'package:zippy/domain/state/search/global_search_state.dart';

class GlobalSearchCubit extends Cubit<GlobalSearchState> {
  final GlobalSearchRepository _searchRepository;
  final TextEditingController searchController = TextEditingController();
  Timer? _searchDebounce;

  GlobalSearchCubit(this._searchRepository) : super(GlobalSearchInitial()) {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    final query = searchController.text.trim();
    if (query.isEmpty) {
      emit(GlobalSearchInitial());
      return;
    }

    // Reduced debounce time for more responsive search
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      print("Debounce timer fired, searching for: $query");
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      print("Empty query, emitting GlobalSearchInitial");
      emit(GlobalSearchInitial());
      return;
    }

    print("Searching for: '$query'");
    emit(GlobalSearchLoading());

    try {
      final results = await _searchRepository.searchGlobal(query);
      print("Search results received: ${results.status}");
      print("Transactions: ${results.transactions.length}");
      print("Contacts: ${results.contacts.length}");
      print("Offers: ${results.offers.length}");

      // Emit the loaded state with showResults explicitly set to true
      emit(GlobalSearchLoaded(results: results, showResults: true));

      // Debug log after emitting state
      print("Emitted GlobalSearchLoaded state");
    } catch (e) {
      print("Search error: $e");
      emit(GlobalSearchError(errorMessage: e.toString()));
    }
  }

  void hideResults() {
    if (state is GlobalSearchLoaded) {
      final currentState = state as GlobalSearchLoaded;
      emit(currentState.copyWith(showResults: false));
    }
  }

  void showResults() {
    if (state is GlobalSearchLoaded) {
      final currentState = state as GlobalSearchLoaded;
      emit(currentState.copyWith(showResults: true));
    }
  }

  void clearSearch() {
    searchController.clear();
    emit(GlobalSearchInitial());
  }

  @override
  Future<void> close() {
    searchController.dispose();
    _searchDebounce?.cancel();
    return super.close();
  }
}
