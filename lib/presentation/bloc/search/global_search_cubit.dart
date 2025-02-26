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

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      search(query);
    });
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(GlobalSearchInitial());
      return;
    }

    emit(GlobalSearchLoading());
    try {
      final results = await _searchRepository.searchGlobal(query);
      emit(GlobalSearchLoaded(results: results, showResults: true));
    } catch (e) {
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
    } else if (searchController.text.isNotEmpty) {
      // If there's text but no loaded state, trigger a search
      search(searchController.text);
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
