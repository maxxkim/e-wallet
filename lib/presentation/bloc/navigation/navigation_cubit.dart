import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/navigation/navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void setTab(NavigationTab tab, GoRouter router) {
    emit(state.copyWith(selectedTab: tab));
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
        // Handle offers navigation when implemented
        break;
      case NavigationTab.support:
        // Support is handled via dialog, no navigation needed
        break;
    }
  }
}
