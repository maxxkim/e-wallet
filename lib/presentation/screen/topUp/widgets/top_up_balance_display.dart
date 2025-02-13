import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class TopUpBalanceDisplay extends StatelessWidget with FadeInAnimationMixin {
  const TopUpBalanceDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Column(
            children: [
              Center(
                child: fadeIn(
                  Text(
                    l10n.totalBalance,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              fadeIn(
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/dollar.svg',
                      height: 32.0,
                      width: 32.0,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      state.balance.toStringAsFixed(
                          state.balance.toString().contains('.') ? 2 : 0),
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ],
                ),
                delay: 100,
              ),
              const SizedBox(height: 24),
              fadeIn(
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.topUpSelectProvider,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                delay: 200,
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
