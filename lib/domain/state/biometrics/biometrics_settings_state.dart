import 'package:local_auth/local_auth.dart';
import 'package:zippy/domain/model/settings/biometric_setting_model.dart';

abstract class BiometricSettingsState {}

class BiometricSettingsLoading extends BiometricSettingsState {}

class BiometricSettingsLoaded extends BiometricSettingsState {
  final BiometricSettings settings;
  final bool isBiometricsAvailable;
  final List<BiometricType> availableBiometricTypes;

  BiometricSettingsLoaded({
    required this.settings,
    required this.isBiometricsAvailable,
    required this.availableBiometricTypes,
  });
}

class BiometricSettingsError extends BiometricSettingsState {
  final String message;

  BiometricSettingsError(this.message);
}
