import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class OfferDataRepository implements OfferRepository {
  final ApiUtil _apiUtil;

  OfferDataRepository(this._apiUtil);

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
    int? categoryId,
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
      categoryId: categoryId,
      merchantId: merchantId,
      sortBy: sortBy,
      filterFrom: filterFrom,
      filterTo: filterTo,
      filterType: filterType,
    );
  }
}
