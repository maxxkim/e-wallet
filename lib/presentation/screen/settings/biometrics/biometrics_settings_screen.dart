import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/biometrics/biometrics_settings_state.dart';
import 'package:zippy/presentation/bloc/auth/pin_setup_screen.dart';
import 'package:zippy/presentation/bloc/biometrics/biometrics_cubit.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';

class BiometricSettingsScreen extends StatelessWidget {
  const BiometricSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsBiometrics),
      ),
      body: BlocBuilder<BiometricSettingsCubit, BiometricSettingsState>(
        builder: (context, state) {
          if (state is BiometricSettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BiometricSettingsError) {
            return _buildErrorView(context, state.message);
          } else if (state is BiometricSettingsLoaded) {
            return _buildSettingsView(context, state, l10n);
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ).animate().scale(duration: 300.ms),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<BiometricSettingsCubit>().loadSettings();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsView(
    BuildContext context,
    BiometricSettingsLoaded state,
    AppLocalizations l10n,
  ) {
    final settings = state.settings;
    final isBiometricsAvailable = state.isBiometricsAvailable;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Biometrics
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      l10n.settingsBiometrics,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isBiometricsAvailable)
                    _buildAvailableBiometricsSection(context, state, l10n),
                  if (!isBiometricsAvailable)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.settingsBiometricsNotAvailable,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  if (isBiometricsAvailable)
                    SwitchListTile(
                      title: Text(l10n.settingsEnableBiometrics),
                      subtitle: Text(l10n.settingsEnableBiometricsDescription),
                      value: settings.enabled,
                      onChanged: (value) {
                        context
                            .read<BiometricSettingsCubit>()
                            .toggleBiometrics(value);
                      },
                      secondary: Icon(
                        Icons.fingerprint,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (isBiometricsAvailable)
                    SwitchListTile(
                      title: Text(l10n.settingsRequireOnAppStart),
                      subtitle: Text(l10n.settingsRequireOnAppStartDescription),
                      value: settings.requireOnAppStart,
                      onChanged: settings.enabled
                          ? (value) {
                              context
                                  .read<BiometricSettingsCubit>()
                                  .toggleRequireOnAppStart(value);
                            }
                          : null,
                      secondary: Icon(
                        Icons.lock_open,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  if (isBiometricsAvailable)
                    SwitchListTile(
                      title: Text(l10n.settingsRequireForTransactions),
                      subtitle:
                          Text(l10n.settingsRequireForTransactionsDescription),
                      value: settings.requireForTransactions,
                      onChanged: settings.enabled
                          ? (value) {
                              context
                                  .read<BiometricSettingsCubit>()
                                  .toggleRequireForTransactions(value);
                            }
                          : null,
                      secondary: Icon(
                        Icons.payments,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section: PIN
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.tertiaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.pin,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'PIN Authentication',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('PIN Settings'),
                    subtitle: Text(
                      settings.pinEnabled
                          ? 'PIN is currently enabled'
                          : 'Set up a PIN for unlocking your wallet',
                    ),
                    trailing: Icon(
                      settings.pinEnabled
                          ? Icons.check_circle
                          : Icons.arrow_forward_ios,
                      color: settings.pinEnabled
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      // Navigate to PIN setup
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PinSetupScreen(),
                        ),
                      ).then((_) {
                        // Refresh settings after returning
                        context.read<BiometricSettingsCubit>().loadSettings();
                      });
                    },
                  ),
                  if (settings.pinEnabled)
                    ListTile(
                      title: const Text('Change PIN'),
                      leading: const Icon(Icons.edit),
                      onTap: () {
                        // Navigate to PIN change
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinSetupScreen(),
                          ),
                        ).then((_) {
                          // Refresh settings after returning
                          context.read<BiometricSettingsCubit>().loadSettings();
                        });
                      },
                    ),
                  if (settings.pinEnabled)
                    ListTile(
                      title: const Text('Disable PIN'),
                      leading: Icon(
                        Icons.no_encryption,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onTap: () async {
                        // Show confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Disable PIN'),
                            content: const Text(
                              'Are you sure you want to disable PIN authentication? '
                              'This will make your wallet less secure if biometrics are unavailable.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Disable'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Disable PIN
                          await context
                              .read<BiometricSettingsCubit>()
                              .disablePin();
                        }
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (settings.enabled || settings.pinEnabled)
              _buildTimeoutSlider(context, state, l10n),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(
            begin: 0.05,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOutQuad,
          ),
    );
  }

  Widget _buildBiometricsNotAvailableView(
      BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_encryption,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
            ).animate().scale(duration: 300.ms),
            const SizedBox(height: 24),
            Text(
              l10n.settingsBiometricsNotAvailable,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.settingsBiometricsNotAvailableDescription,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableBiometricsSection(
    BuildContext context,
    BiometricSettingsLoaded state,
    AppLocalizations l10n,
  ) {
    final biometricTypes = state.availableBiometricTypes;
    if (biometricTypes.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsAvailableBiometrics,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: biometricTypes.map((type) {
              IconData icon;
              String label;
              switch (type) {
                case BiometricType.face:
                  icon = Icons.face;
                  label = l10n.settingsBiometricFace;
                  break;
                case BiometricType.fingerprint:
                  icon = Icons.fingerprint;
                  label = l10n.settingsBiometricFingerprint;
                  break;
                case BiometricType.iris:
                  icon = Icons.remove_red_eye;
                  label = l10n.settingsBiometricIris;
                  break;
                case BiometricType.strong:
                  icon = Icons.security;
                  label = l10n.settingsBiometricStrong;
                  break;
                case BiometricType.weak:
                  icon = Icons.lock_open;
                  label = l10n.settingsBiometricWeak;
                  break;
              }
              return Chip(
                avatar: Icon(icon, size: 18),
                label: Text(label),
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeoutSlider(
    BuildContext context,
    BiometricSettingsLoaded state,
    AppLocalizations l10n,
  ) {
    final settings = state.settings;

    const timeoutOptions = [15, 30, 60, 120, 300, 600];
    final currentTimeoutIndex = timeoutOptions
        .indexWhere((timeout) => timeout >= settings.lockTimeoutSeconds);
    final currentIndex = currentTimeoutIndex == -1
        ? timeoutOptions.length - 1
        : currentTimeoutIndex;

    String _formatDuration(int seconds) {
      if (seconds < 60) {
        return '$seconds ${l10n.settingsSeconds}';
      } else {
        return '${seconds ~/ 60} ${l10n.settingsMinutes}';
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Text(
                  l10n.settingsLockTimeout,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.settingsLockTimeoutDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.settingsLockTimeoutShorter),
                Text(l10n.settingsLockTimeoutLonger),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4.0,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20.0),
              ),
              child: Slider(
                value: currentIndex.toDouble(),
                min: 0,
                max: (timeoutOptions.length - 1).toDouble(),
                divisions: timeoutOptions.length - 1,
                label: _formatDuration(timeoutOptions[currentIndex]),
                onChanged: (value) {
                  final timeout = timeoutOptions[value.round()];
                  context
                      .read<BiometricSettingsCubit>()
                      .updateLockTimeout(timeout);
                },
              ),
            ),
            Center(
              child: Text(
                _formatDuration(settings.lockTimeoutSeconds),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
