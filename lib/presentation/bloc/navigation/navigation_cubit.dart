import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/navigation/navigation_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void setTab(NavigationTab tab, GoRouter router) {
    // Check if we're navigating to the home tab
    final wasOnHomeTab = state.selectedTab == NavigationTab.home;
    final goingToHomeTab = tab == NavigationTab.home;

    emit(state.copyWith(selectedTab: tab));

    // If navigating to home tab, refresh dashboard if we weren't already there
    if (goingToHomeTab && !wasOnHomeTab) {
      try {
        final context = router.routerDelegate.navigatorKey.currentContext;
        if (context != null) {
          context.read<DashboardCubit>().loadData();
        }
      } catch (_) {
        // Handle silently
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
        // Handle support tab
        break;
    }
  }
}
