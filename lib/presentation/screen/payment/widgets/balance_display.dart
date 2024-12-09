import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class BalanceDisplay extends StatelessWidget with FadeInAnimationMixin {
  const BalanceDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Container(
            height: 146,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    top: 16,
                    bottom: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fadeIn(
                        Text(
                          l10n.totalBalance,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 8),
                      fadeIn(
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/dollar.svg',
                              height: 32.0,
                              width: 32.0,
                            ),
                            const SizedBox(width: 12.0),
                            Text(
                              state.balance.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ],
                        ),
                        delay: 100,
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                fadeIn(
                  Container(
                    height: 48.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: Theme.of(context)
                          .extension<ThemeGradients>()
                          ?.darkBlueGradient,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.dashboardSelectFromContacts,
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ),
                  delay: 200,
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
