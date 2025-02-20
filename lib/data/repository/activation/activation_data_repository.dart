// lib/data/repository/activation/activation_data_repository.dart

import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/repository/activation/activation_repository.dart';

class ActivationDataRepository implements ActivationRepository {
  final ApiUtil _apiUtil;

  ActivationDataRepository(this._apiUtil);

  @override
  Future<List<Activation>> getAllActivations() async {
    return _apiUtil.getAllActivations();
  }

  @override
  Future<Activation> getActivationByUserAndOffer(
      String userId, int offerId) async {
    return _apiUtil.getActivationByUserAndOffer(userId, offerId);
  }

  @override
  Future<Activation> checkActivationByUserAndMerchant(
      String userId, String merchantId) async {
    return _apiUtil.checkActivationByUserAndMerchant(userId, merchantId);
  }

  @override
  Future<Activation> checkActivationById(String activationId) async {
    return _apiUtil.checkActivationById(activationId);
  }

  @override
  Future<void> completeActivation(String activationId) async {
    await _apiUtil.completeActivation(activationId);
  }

  @override
  Future<Activation> activateOffer(int offerId) async {
    return _apiUtil.activateOffer(offerId);
  }
}
