// lib/data/repository/search/global_search_data_repository.dart
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/search/global_search_model.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';

class GlobalSearchDataRepository implements GlobalSearchRepository {
  final ApiUtil _apiUtil;

  GlobalSearchDataRepository(this._apiUtil);

  @override
  Future<GlobalSearchResponse> searchGlobal(String query, {int limit = 5}) {
    return _apiUtil.searchGlobal(query, limit: limit);
  }
}
