import 'package:zippy/domain/model/offer/activation_model.dart';
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
    int? categoryId,
    String? merchantId,
    String? sortBy = 'desc',
    String? filterFrom,
    String? filterTo,
    String? filterType,
  });
  Future<List<Offer>> getTopOffers({
    int limit = 5,
  });
}
