import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';
import 'package:zippy/domain/state/withdrawal/withdrawal_state.dart';

class WithdrawalCubit extends Cubit<WithdrawalState> {
  final WithdrawalRepository _withdrawalRepository;
  WithdrawalCubit(this._withdrawalRepository) : super(WithdrawalStateLoading());

  static Future<WithdrawalCubit> create(
      WithdrawalRepository withdrawalRepository) async {
    final cubit = WithdrawalCubit(withdrawalRepository);
    await cubit.loadData();
    return cubit;
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response?.data != null &&
          error.response?.data['status'] == 'error' &&
          error.response?.data['message'] != null) {
        return error.response?.data['message'];
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return 'Connection timeout occurred';
        case DioExceptionType.sendTimeout:
          return 'Send timeout exceeded';
        case DioExceptionType.receiveTimeout:
          return 'Receive timeout exceeded';
        case DioExceptionType.badResponse:
          return 'Server error: ${error.response?.statusCode}';
        case DioExceptionType.cancel:
          return 'Request cancelled';
        default:
          return 'An unknown error occurred';
      }
    }
    return error.toString();
  }

  Future<void> loadData() async {
    try {
      final withdrawal = await _withdrawalRepository.getProviders();
      emit(WithdrawalStateLoaded(providers: withdrawal.providerList));
    } catch (e) {
      emit(WithdrawalStateError(errorMessage: _handleError(e)));
    }
  }

  Future<void> initializeWithdrawal(
      Map<String, dynamic> data, GoRouter router) async {
    try {
      final withdrawalInitiate =
          await _withdrawalRepository.initiateWithdrawal(data);
      emit(WithdrawalStateInitiated(url: withdrawalInitiate.paymentUrl));
      router.go('/dashboard');
    } catch (e) {
      emit(WithdrawalStateError(errorMessage: _handleError(e)));
    }
  }
}
