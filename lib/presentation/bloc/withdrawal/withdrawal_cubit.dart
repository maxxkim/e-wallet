import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadData() async {
    try {
      final withdrawal = await _withdrawalRepository.getProviders();
      emit(WithdrawalStateLoaded(providers: withdrawal.providerList));
    } catch (e) {
      emit(WithdrawalStateError(errorMessage: e.toString()));
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
      emit(WithdrawalStateError(errorMessage: e.toString()));
    }
  }
}
