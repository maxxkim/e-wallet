import 'package:zippy/domain/model/top_up/provider_model.dart';

class ApiTopUp {
  final List<Provider> providerList;

  ApiTopUp.fromApi(Map<String, dynamic> json)
      : providerList = (json['providers'] as List<dynamic>?)
                ?.map((providerMap) => Provider.fromJson(providerMap))
                .toList() ??
            [];
}
