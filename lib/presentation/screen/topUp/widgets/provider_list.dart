import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/bloc/topUp/top_up_cubit.dart';
import 'package:zippy/presentation/bloc/withdrawal/withdrawal_cubit.dart';
import 'package:zippy/presentation/screen/topUp/widgets/provider_card.dart';

class ProviderList extends StatelessWidget {
  final List<Provider> providers;
  final bool isWithdrawal;

  const ProviderList({
    super.key,
    required this.providers,
    this.isWithdrawal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return ProviderCard(
          provider: providers[index],
          isWithdrawal: isWithdrawal,
          onSubmit: (data, router) async {
            if (isWithdrawal) {
              await context
                  .read<WithdrawalCubit>()
                  .initializeWithdrawal(data, router);
            } else {
              await context.read<TopUpCubit>().initializeTopUp(data, router);
            }
          },
        );
      },
    );
  }
}
