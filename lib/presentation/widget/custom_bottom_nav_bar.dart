// Modified CustomBottomNavBar with Settings tab
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/navigation/navigation_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/bloc/navigation/navigation_cubit.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final router = GoRouter.of(context);
    return BlocBuilder<NavigationCubit, NavigationState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
          child: SafeArea(
            child: Container(
              height: 88,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    tab: NavigationTab.history,
                    label: l10n.navHistory,
                    icon: SvgPicture.asset('assets/images/navbar_history.svg'),
                    selectedIcon: SvgPicture.asset(
                        'assets/images/navbar_history_active.svg'),
                    selectedTab: state.selectedTab,
                    router: router,
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.transfer,
                    label: l10n.navTransfer,
                    icon: SvgPicture.asset('assets/images/navbar_transfer.svg'),
                    selectedIcon: SvgPicture.asset(
                        'assets/images/navbar_transfer_active.svg'),
                    selectedTab: state.selectedTab,
                    router: router,
                  ),
                  _buildCenterButton(context, state.selectedTab, router),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.offers,
                    label: l10n.navOffers,
                    icon: SvgPicture.asset('assets/images/navbar_offer.svg'),
                    selectedIcon: SvgPicture.asset(
                        'assets/images/navbar_offer_active.svg'),
                    selectedTab: state.selectedTab,
                    router: router,
                  ),
                  _buildNavItem(
                    context,
                    tab: NavigationTab.support,
                    label: l10n.navSupport,
                    icon: SvgPicture.asset('assets/images/navbar_support.svg'),
                    selectedIcon: SvgPicture.asset(
                        'assets/images/navbar_support_active.svg'),
                    selectedTab: state.selectedTab,
                    router: router,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required NavigationTab tab,
    required String label,
    required Widget icon,
    required Widget selectedIcon,
    required NavigationTab selectedTab,
    required GoRouter router,
  }) {
    final isSelected = selectedTab == tab;
    return InkWell(
      onTap: () {
        // If already on home tab and clicked again, refresh
        if (tab == NavigationTab.home && selectedTab == NavigationTab.home) {
          try {
            context.read<DashboardCubit>().loadData();
          } catch (_) {
            // Ignore any error when refreshing
          }
        }
        context.read<NavigationCubit>().setTab(tab, router);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        width: 64,
        height: 56,
        child: isSelected
            ? Center(child: selectedIcon)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCenterButton(
    BuildContext context,
    NavigationTab selectedTab,
    GoRouter router,
  ) {
    final isSelected = selectedTab == NavigationTab.home;
    return GestureDetector(
      onTap: () =>
          context.read<NavigationCubit>().setTab(NavigationTab.home, router),
      child: Container(
        height: 72,
        width: 72,
        margin: const EdgeInsets.only(bottom: 8),
        child: isSelected
            ? SvgPicture.asset("assets/images/navbar_home_active.svg")
            : SvgPicture.asset("assets/images/navbar_home.svg"),
      ),
    );
  }
}
