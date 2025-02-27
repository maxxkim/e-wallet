// lib/domain/repository/offer/offer_repository.dart

import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/initial_data_model.dart';

abstract class OfferRepository {
  Future<InitialDataResponse> getInitialData({
    int limit = 15,
    int topLimit = 5,
    int page = 1,
  });

  Future<List<Activation>> getActivations({
    int limit = 20,
  });

  Future<Activation> activateOffer(
    int offerId,
  );

  Future<List<CategoryModel>> getFavoriteCategories({int limit = 100});

  Future<List<CategoryModel>> addFavoriteCategory(int categoryId);

  Future<List<CategoryModel>> deleteFavoriteCategory(int categoryId);
}
