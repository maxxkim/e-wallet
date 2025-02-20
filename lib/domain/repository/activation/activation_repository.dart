import 'package:zippy/domain/model/offer/activation_model.dart';

abstract class ActivationRepository {
  Future<List<Activation>> getAllActivations();

  Future<Activation> getActivationByUserAndOffer(String userId, int offerId);

  Future<Activation> checkActivationByUserAndMerchant(
      String userId, String merchantId);

  Future<Activation> checkActivationById(String activationId);

  Future<void> completeActivation(String activationId);

  Future<Activation> activateOffer(int offerId);
}
