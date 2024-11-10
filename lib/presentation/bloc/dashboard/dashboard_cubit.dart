import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit(this._dashboardRepository)
      : super(DashboardStateLoaded(
          filterType: FilterType.period,
          chosenMonth: DateFormat('MMMM').format(DateTime.now()),
          balance: 0,
          transactions: [],
          filteredTransactions: [],
        ));

  static Future<DashboardCubit> create(
      DashboardRepository dashboardRepository) async {
    final cubit = DashboardCubit(dashboardRepository);
    await cubit.loadData();
    return cubit;
  }

  Future<void> loadData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String accessToken = prefs.getString('accessToken') ?? '';
      if (accessToken.isEmpty) {
        emit(DashboardStateError(errorMessage: 'Sign in token is missing'));
        return;
      }

      final balance = await _dashboardRepository.getBalance();
      final transactions = await _dashboardRepository.getTransactions();

      emit(DashboardStateLoaded(
        filterType: FilterType.period,
        chosenMonth: DateFormat('MMMM').format(DateTime.now()),
        balance: balance,
        transactions: transactions,
        filteredTransactions: transactions,
        accessToken: accessToken,
      ));
    } catch (e) {
      emit(DashboardStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      emit(DashboardStateLoggedOut());
    } catch (e) {
      emit(DashboardStateError(
        errorMessage: _handleError(e),
      ));
    }
  }

  void selectFilter(FilterType filterType) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      List<Transaction>? filteredTransactions = filterTransactions(
          filterType, currentState.transactions, currentState.chosenMonth);
      emit(currentState.copyWith(
        filterType: filterType,
        filteredTransactions: filteredTransactions,
      ));
    }
  }

  void selectMonth(String month) {
    if (state is DashboardStateLoaded) {
      var currentState = state as DashboardStateLoaded;
      List<Transaction>? filteredTransactions = filterTransactions(
          currentState.filterType, currentState.transactions, month);
      emit(currentState.copyWith(
        chosenMonth: month,
        filteredTransactions: filteredTransactions,
      ));
    }
  }

  List<Transaction>? filterTransactions(
      FilterType filterType, List<Transaction>? transactions, String? month) {
    if (transactions == null) return null;

    if (filterType == FilterType.deposit) {
      return transactions
          .where((transaction) => transaction.type == 'payin')
          .toList();
    } else if (filterType == FilterType.withdrawal) {
      return transactions
          .where((transaction) => transaction.type == 'payout')
          .toList();
    } else if (filterType == FilterType.period) {
      return transactions
          .where((transaction) =>
              DateFormat('MMMM').format(transaction.date) == month)
          .toList();
    }
    return transactions;
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection error. Please try again.';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded.';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded.';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        default:
          return 'An unknown error occurred.';
      }
    }
    return error.toString();
  }
}
