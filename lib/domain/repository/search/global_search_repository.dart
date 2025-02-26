import 'package:zippy/domain/model/search/global_search_model.dart';

abstract class GlobalSearchRepository {
  Future<GlobalSearchResponse> searchGlobal(String query, {int limit = 5});
}
