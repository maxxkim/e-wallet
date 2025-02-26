// lib/domain/state/search/global_search_state.dart
import 'package:zippy/domain/model/search/global_search_model.dart';

abstract class GlobalSearchState {}

class GlobalSearchInitial extends GlobalSearchState {}

class GlobalSearchLoading extends GlobalSearchState {}

class GlobalSearchLoaded extends GlobalSearchState {
  final GlobalSearchResponse results;
  final bool showResults;

  GlobalSearchLoaded({
    required this.results,
    this.showResults = true,
  });

  GlobalSearchLoaded copyWith({
    GlobalSearchResponse? results,
    bool? showResults,
  }) {
    return GlobalSearchLoaded(
      results: results ?? this.results,
      showResults: showResults ?? this.showResults,
    );
  }
}

class GlobalSearchError extends GlobalSearchState {
  final String errorMessage;

  GlobalSearchError({required this.errorMessage});
}
