import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class OfferDataRepository implements OfferRepository {
  final ApiUtil _apiUtil;
  OfferDataRepository(this._apiUtil);

  @override
  Future<List<String>> getOfferTypes() {
    return _apiUtil.getOfferTypes();
  }

  @override
  Future<List<Activation>> getActivations({int limit = 20}) {
    return _apiUtil.getActivations(limit: limit);
  }

  @override
  Future<Activation> activateOffer(int offerId) {
    return _apiUtil.activateOffer(offerId);
  }

  @override
  Future<List<Offer>> getOffers({
    int page = 1,
    int limit = 100,
    String? search,
    List<int>? categoryIds,
    String? merchantId,
    String? sortBy = 'desc',
    String? filterFrom,
    String? filterTo,
    String? filterType,
  }) {
    return _apiUtil.getOffers(
      page: page,
      limit: limit,
      search: search,
      categoryIds: categoryIds,
      merchantId: merchantId,
      sortBy: sortBy,
      filterFrom: filterFrom,
      filterTo: filterTo,
      filterType: filterType,
    );
  }

  @override
  Future<List<Offer>> getTopOffers({int limit = 5}) {
    return _apiUtil.getTopOffers(limit: limit);
  }

  @override
  Future<List<CategoryModel>> getCategories({int limit = 20, String? search}) {
    return _apiUtil.getCategories(limit: limit, search: search);
  }

  @override
  Future<List<CategoryModel>> getFavoriteCategories({int limit = 100}) {
    return _apiUtil.getFavoriteCategories(limit: limit);
  }

  @override
  Future<List<CategoryModel>> addFavoriteCategory(int categoryId) {
    return _apiUtil.addFavoriteCategory(categoryId);
  }

  @override
  Future<List<CategoryModel>> deleteFavoriteCategory(int categoryId) {
    return _apiUtil.deleteFavoriteCategory(categoryId);
  }

  @override
  Future<List<Map<String, dynamic>>> getMerchants({
    int limit = 20,
    String? search,
  }) {
    return _apiUtil.getMerchants(limit: limit, search: search);
  }
}
