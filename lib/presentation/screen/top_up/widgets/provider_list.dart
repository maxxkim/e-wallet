import 'package:flutter/material.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/presentation/screen/top_up/widgets/provider_card.dart';

class ProviderList extends StatelessWidget {
  final List<Provider> providers;

  const ProviderList({
    super.key,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return ProviderCard(provider: providers[index]);
      },
    );
  }
}
