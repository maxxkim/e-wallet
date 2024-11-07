import 'package:zippy/domain/model/top_up/parameter_model.dart';

class Provider {
  final String name;
  final String description;
  final String logo;
  final List<Parameter> parameters;

  Provider({
    required this.name,
    required this.description,
    required this.logo,
    required this.parameters,
  });
}
