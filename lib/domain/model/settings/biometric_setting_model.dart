// lib/domain/model/settings/biometric_settings_model.dart
class BiometricSettings {
  final bool enabled;
  final int lockTimeoutSeconds;
  final bool requireOnAppStart;
  final bool requireForTransactions;

  const BiometricSettings({
    this.enabled = false,
    this.lockTimeoutSeconds = 15,
    this.requireOnAppStart = true,
    this.requireForTransactions = true,
  });

  BiometricSettings copyWith({
    bool? enabled,
    int? lockTimeoutSeconds,
    bool? requireOnAppStart,
    bool? requireForTransactions,
  }) {
    return BiometricSettings(
      enabled: enabled ?? this.enabled,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      requireOnAppStart: requireOnAppStart ?? this.requireOnAppStart,
      requireForTransactions:
          requireForTransactions ?? this.requireForTransactions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'lock_timeout_seconds': lockTimeoutSeconds,
      'require_on_app_start': requireOnAppStart,
      'require_for_transactions': requireForTransactions,
    };
  }

  factory BiometricSettings.fromJson(Map<String, dynamic> json) {
    return BiometricSettings(
      enabled: json['enabled'] ?? false,
      lockTimeoutSeconds: json['lock_timeout_seconds'] ?? 60,
      requireOnAppStart: json['require_on_app_start'] ?? true,
      requireForTransactions: json['require_for_transactions'] ?? true,
    );
  }
}
