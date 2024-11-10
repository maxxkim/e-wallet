import 'package:zippy/domain/model/top_up/provider_model.dart';

abstract class WithdrawalState {}

class WithdrawalStateLoading extends WithdrawalState {}

class WithdrawalStateLoaded extends WithdrawalState {
  final List<Provider> providers;
  WithdrawalStateLoaded({required this.providers});
}

class WithdrawalStateError extends WithdrawalState {
  final String errorMessage;
  WithdrawalStateError({required this.errorMessage});
}

class WithdrawalStateInitiated extends WithdrawalState {
  final String url;
  WithdrawalStateInitiated({required this.url});
}
