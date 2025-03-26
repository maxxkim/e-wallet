import 'package:equatable/equatable.dart';

enum NavigationTab { history, transfer, home, offers, support }

class NavigationState extends Equatable {
  final NavigationTab selectedTab;

  const NavigationState({
    this.selectedTab = NavigationTab.home,
  });

  NavigationState copyWith({
    NavigationTab? selectedTab,
  }) {
    return NavigationState(
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [selectedTab];
}
