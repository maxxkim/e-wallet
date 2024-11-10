import 'package:zippy/domain/model/top_up/provider_model.dart';

abstract class TopUpState {}

class TopUpStateLoading extends TopUpState {}

class TopUpStateLoaded extends TopUpState {
  final List<Provider> providers;

  TopUpStateLoaded({required this.providers});
}

class TopUpStateError extends TopUpState {
  final String errorMessage;

  TopUpStateError({required this.errorMessage});
}

class TopUpStateInitiated extends TopUpState {
  final String url;

  TopUpStateInitiated({required this.url});
}
