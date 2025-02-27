// lib/data/repository/offer/offer_data_repository.dart

import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/initial_data_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class OfferDataRepository implements OfferRepository {
  final ApiUtil _apiUtil;

  OfferDataRepository(this._apiUtil);

  @override
  Future<InitialDataResponse> getInitialData({
    int limit = 15,
    int topLimit = 5,
    int page = 1,
  }) {
    return _apiUtil.getInitialData(
      limit: limit,
      topLimit: topLimit,
      page: page,
    );
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
}
