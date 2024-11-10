import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> loadData() async {
    try {
      final topUp = await _topUpRepository.getProviders();
      emit(TopUpStateLoaded(providers: topUp.providerList));
    } catch (e) {
      emit(TopUpStateError(errorMessage: e.toString()));
    }
  }

  Future<void> initializeTopUp(Map<String, dynamic> data) async {
    try {
      final topUpInitiate = await _topUpRepository.initiateTopUp(data);
      emit(TopUpStateInitiated(url: topUpInitiate.paymentUrl));
    } catch (e) {
      emit(TopUpStateError(errorMessage: e.toString()));
    }
  }
}
