import 'package:zippy/domain/model/offer/banner_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';

enum FilterType { period, deposit, withdrawal }

enum NavigationTab { home, history, action, cards, profile }

abstract class DashboardState {}

class DashboardStateLoaded extends DashboardState {
  final FilterType filterType;
  final String chosenMonth;
  final num balance;
  final String? accessToken;
  final List<Transaction>? transactions;
  final List<Transaction>? filteredTransactions;
  final String searchQuery;
  final NavigationTab selectedTab;
  final List<OfferBanner>? banners;
  DashboardStateLoaded({
    required this.filterType,
    required this.chosenMonth,
    required this.balance,
    required this.transactions,
    required this.filteredTransactions,
    this.accessToken,
    this.searchQuery = '',
    this.selectedTab = NavigationTab.home,
    this.banners,
  });

  int get selectedMonthNumber {
    final Map<String, int> monthMap = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
    };
    return monthMap[chosenMonth] ?? DateTime.now().month;
  }

  DashboardStateLoaded copyWith({
    FilterType? filterType,
    String? chosenMonth,
    num? balance,
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    String? accessToken,
    String? searchQuery,
    NavigationTab? selectedTab,
    List<OfferBanner>? banners,
  }) {
    return DashboardStateLoaded(
      filterType: filterType ?? this.filterType,
      chosenMonth: chosenMonth ?? this.chosenMonth,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      accessToken: accessToken ?? this.accessToken,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTab: selectedTab ?? this.selectedTab,
      banners: banners ?? this.banners,
    );
  }
}

class DashboardStateError extends DashboardState {
  final String errorMessage;
  DashboardStateError({
    required this.errorMessage,
  });
}

class DashboardStateLoggedOut extends DashboardState {}
