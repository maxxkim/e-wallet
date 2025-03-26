import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/navigation/navigation_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void setTab(NavigationTab tab, GoRouter router) {
    // Check if we're already on home tab and going to home tab again
    final wasOnHomeTab = state.selectedTab == NavigationTab.home;
    final goingToHomeTab = tab == NavigationTab.home;

    emit(state.copyWith(selectedTab: tab));

    // Only refresh data if we're navigating back to home from another tab
    if (goingToHomeTab && !wasOnHomeTab) {
      try {
        final context = router.routerDelegate.navigatorKey.currentContext;
        if (context != null) {
          context.read<DashboardCubit>().loadData();
        }
      } catch (_) {
        // Ignore errors during data loading
      }
    }

    _handleNavigation(tab, router);
  }

  void _handleNavigation(NavigationTab tab, GoRouter router) {
    switch (tab) {
      case NavigationTab.history:
        router.go('/dashboard/history');
        break;
      case NavigationTab.transfer:
        router.go('/dashboard/transfer');
        break;
      case NavigationTab.home:
        router.go('/dashboard');
        break;
      case NavigationTab.offers:
        router.go('/dashboard/offers');
        break;
      case NavigationTab.support:
        router.go('/dashboard/logs');
        break;
    }
  }
}
