import 'package:zippy/domain/model/offer/activation_model.dart';

class ActivationsResponse {
  final List<Activation> activations;

  ActivationsResponse({required this.activations});

  factory ActivationsResponse.fromJson(Map<String, dynamic> json) {
    return ActivationsResponse(
      activations: (json['activations'] as List)
          .map((e) => Activation.fromJson(e))
          .toList(),
    );
  }
}

class ActivationResponse {
  final Activation activation;

  ActivationResponse({required this.activation});

  factory ActivationResponse.fromJson(Map<String, dynamic> json) {
    return ActivationResponse(
      activation: Activation.fromJson(json['activation']),
    );
  }
}
