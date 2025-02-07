import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';

abstract class OfferRepository {
  Future<List<Activation>> getActivations({
    int limit = 20,
  });

  Future<Activation> activateOffer(
    int offerId,
  );

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
  });

  Future<List<Offer>> getTopOffers({
    int limit = 5,
  });

  Future<List<CategoryModel>> getCategories({int limit = 20, String? search});
  Future<List<CategoryModel>> getFavoriteCategories({int limit = 100});
  Future<List<CategoryModel>> addFavoriteCategory(int categoryId);
  Future<List<CategoryModel>> deleteFavoriteCategory(int categoryId);

  Future<List<Map<String, dynamic>>> getMerchants({
    int limit = 20,
    String? search,
  });
  Future<List<String>> getOfferTypes();
}
