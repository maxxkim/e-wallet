class BiometricSettings {
  final bool enabled;
  final int lockTimeoutSeconds;
  final bool requireOnAppStart;
  final bool requireForTransactions;
  final bool pinEnabled;
  final String? pinCode;

  const BiometricSettings({
    this.enabled = false,
    this.lockTimeoutSeconds = 15,
    this.requireOnAppStart = true,
    this.requireForTransactions = true,
    this.pinEnabled = false,
    this.pinCode,
  });

  BiometricSettings copyWith({
    bool? enabled,
    int? lockTimeoutSeconds,
    bool? requireOnAppStart,
    bool? requireForTransactions,
    bool? pinEnabled,
    String? pinCode,
  }) {
    return BiometricSettings(
      enabled: enabled ?? this.enabled,
      lockTimeoutSeconds: lockTimeoutSeconds ?? this.lockTimeoutSeconds,
      requireOnAppStart: requireOnAppStart ?? this.requireOnAppStart,
      requireForTransactions:
          requireForTransactions ?? this.requireForTransactions,
      pinEnabled: pinEnabled ?? this.pinEnabled,
      pinCode: pinCode ?? this.pinCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'lock_timeout_seconds': lockTimeoutSeconds,
      'require_on_app_start': requireOnAppStart,
      'require_for_transactions': requireForTransactions,
      'pin_enabled': pinEnabled,
      'pin_code': pinCode,
    };
  }

  factory BiometricSettings.fromJson(Map<String, dynamic> json) {
    return BiometricSettings(
      enabled: json['enabled'] ?? false,
      lockTimeoutSeconds: json['lock_timeout_seconds'] ?? 15,
      requireOnAppStart: json['require_on_app_start'] ?? true,
      requireForTransactions: json['require_for_transactions'] ?? true,
      pinEnabled: json['pin_enabled'] ?? false,
      pinCode: json['pin_code'],
    );
  }

  @override
  String toString() {
    return 'BiometricSettings(enabled: $enabled, lockTimeoutSeconds: $lockTimeoutSeconds, requireOnAppStart: $requireOnAppStart, requireForTransactions: $requireForTransactions, pinEnabled: $pinEnabled)';
  }
}
