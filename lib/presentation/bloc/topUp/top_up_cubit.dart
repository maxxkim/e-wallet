import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/domain/state/topUp/top_up_state.dart';

class TopUpCubit extends Cubit<TopUpState> {
  final TopUpRepository _topUpRepository;
  TopUpCubit(this._topUpRepository) : super(TopUpStateLoading());

  static Future<TopUpCubit> create(TopUpRepository topUpRepository) async {
    final cubit = TopUpCubit(topUpRepository);
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
      final topUp = await _topUpRepository.getProviders();
      emit(TopUpStateLoaded(providers: topUp.providerList));
    } catch (e) {
      emit(TopUpStateError(errorMessage: _handleError(e)));
    }
  }

  Future<void> initializeTopUp(
      Map<String, dynamic> data, GoRouter router) async {
    try {
      final topUpInitiate = await _topUpRepository.initiateTopUp(data);
      emit(TopUpStateInitiated(url: topUpInitiate.paymentUrl));
      router.go('/dashboard');
    } catch (e) {
      emit(TopUpStateError(errorMessage: _handleError(e)));
    }
  }
}
