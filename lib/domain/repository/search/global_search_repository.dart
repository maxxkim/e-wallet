import 'package:zippy/domain/model/search/global_search_model.dart';
import 'package:zippy/data/api/api_util.dart';

class GlobalSearchRepository {
  final ApiUtil _apiUtil;

  GlobalSearchRepository(this._apiUtil);

  Future<GlobalSearchResponse> searchGlobal(String query,
      {int limit = 5}) async {
    try {
      // Don't search with very short queries to prevent API errors
      if (query.isEmpty || query.length < 2) {
        // Return empty but valid response
        return GlobalSearchResponse(
            status: 'success',
            contacts: [],
            transactions: [],
            offers: [],
            categories: [],
            merchants: [],
            options: SearchOptions(search: query, limit: limit));
      }

      final result = await _apiUtil.searchGlobal(query, limit: limit);
      return result;
    } catch (e) {
      print("Error in repository: $e");
      // Return safe empty response instead of throwing
      return GlobalSearchResponse(
          status: 'error',
          contacts: [],
          transactions: [],
          offers: [],
          categories: [],
          merchants: [],
          options: SearchOptions(search: query, limit: limit));
    }
  }
}
