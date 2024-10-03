import 'package:flutter_bloc/flutter_bloc.dart';

// Define an enum for the filter types
enum FilterType { period, deposit, withdrawal }

// State class to hold the current filter type
class DashboardState {
  final FilterType filterType;

  const DashboardState(this.filterType);
}

// Cubit class for managing the dashboard state
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(const DashboardState(FilterType.period));

  void selectFilter(FilterType filterType) {
    emit(DashboardState(filterType));
  }
}