import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository _dashboardRepository;

  DashboardCubit(this._dashboardRepository)
      : super(DashboardStateLoaded(
          filterType: FilterType.period,
          chosenMonth: DateFormat('MMMM').format(DateTime.now()),
          balance: 0.0,
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
      //final balance = await _dashboardRepository.getBalance();
      //final transactions = await _dashboardRepository.getTransactions();
      final balance = getRandomBalance();
      final transactions = getRandomTransactions();

      emit(DashboardStateLoaded(
        filterType: FilterType.period,
        chosenMonth: DateFormat('MMMM').format(DateTime.now()),
        balance: balance,
        transactions: transactions,
        filteredTransactions: transactions,
      ));
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
          FilterType.period, currentState.transactions, month);

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
          .where((transaction) => transaction.type == 'deposit')
          .toList();
    } else if (filterType == FilterType.withdrawal) {
      return transactions
          .where((transaction) => transaction.type == 'withdraw')
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
    // Здесь вы можете обрабатывать различные типы ошибок и возвращать соответствующие сообщения
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Ошибка подключения. Попробуйте еще раз.';
        case DioExceptionType.connectionError:
          return 'Ошибка подключения. Попробуйте еще раз.';
        case DioExceptionType.sendTimeout:
          return 'Время ожидания отправки истекло.';
        case DioExceptionType.receiveTimeout:
          return 'Время ожидания получения ответа истекло.';
        case DioExceptionType.badResponse:
          return 'Ошибка сервера: ${error.response?.statusCode}.';
        case DioExceptionType.badCertificate:
          return 'Ошибка сертификата.';
        case DioExceptionType.cancel:
          return 'Запрос отменен.';
        case DioExceptionType.unknown:
          return 'Произошла неизвестная ошибка.';
      }
    }
    return error.toString();
  }

  static double getRandomBalance() {
    final Random random = Random();
    return (random.nextDouble() * 1000000).roundToDouble(); // Случайная сумма
  }

  static List<Transaction> getRandomTransactions() {
    final Random random = Random();
    int numberOfTransactions =
        20 + random.nextInt(31); // Генерирует число от 20 до 50

    List<Transaction> transactions = [];

    for (int i = 0; i < numberOfTransactions; i++) {
      transactions.add(Transaction.generateRandomTransaction());
    }
    return transactions;
  }
}
