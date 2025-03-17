// lib/presentation/screen/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/biometrics/biometrics_settings_state.dart';
import 'package:zippy/presentation/bloc/biometrics/biometrics_cubit.dart';
import 'package:zippy/presentation/bloc/locale/locale_cubit.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentTheme = context.watch<ThemeCubit>().state;
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          l10n.settingsTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          // App settings section
          _buildSectionHeader(context, l10n.settingsAppSection),

          // Theme setting
          ListTile(
            leading: Icon(
              Icons.palette_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.settingsTheme),
            subtitle: Text(
              currentTheme == AppTheme.light
                  ? l10n.settingsThemeLight
                  : l10n.settingsThemeDark,
            ),
            trailing: IconButton(
              icon: Icon(
                currentTheme == AppTheme.light
                    ? Icons.light_mode
                    : Icons.dark_mode,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),

          // Language setting
          ListTile(
            leading: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(l10n.settingsLanguage),
            subtitle: Text(
              currentLocale.languageCode == 'en'
                  ? l10n.settingsLanguageEnglish
                  : l10n.settingsLanguageSpanish,
            ),
            trailing: PopupMenuButton<String>(
              icon: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onSelected: (value) {
                final newLocale = Locale(value);
                context.read<LocaleCubit>().changeLocale(newLocale);
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'en',
                  child: Text(l10n.settingsLanguageEnglish),
                ),
                PopupMenuItem(
                  value: 'es',
                  child: Text(l10n.settingsLanguageSpanish),
                ),
              ],
            ),
          ),

          // Security section
          _buildSectionHeader(context, l10n.settingsSecuritySection),

          // Biometric authentication settings
          BlocBuilder<BiometricSettingsCubit, BiometricSettingsState>(
            builder: (context, state) {
              bool biometricsAvailable = false;
              if (state is BiometricSettingsLoaded) {
                biometricsAvailable = state.isBiometricsAvailable;
              }

              return biometricsAvailable
                  ? ListTile(
                      leading: Icon(
                        Icons.fingerprint,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(l10n.settingsBiometrics),
                      subtitle: Text(
                        state is BiometricSettingsLoaded &&
                                state.settings.enabled
                            ? l10n.settingsBiometricsEnabled
                            : l10n.settingsBiometricsDisabled,
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onTap: () {
                        context.go('/dashboard/settings/biometrics');
                      },
                    )
                  : const SizedBox.shrink();
            },
          ),

          // Account section
          _buildSectionHeader(context, l10n.settingsAccountSection),

          // Logout option
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              l10n.settingsLogout,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () {
              _showLogoutConfirmationDialog(context, l10n);
            },
          ),

          // App info
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Text(
                  'Zentro Wallet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(
      BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.settingsLogoutConfirmTitle),
          content: Text(l10n.settingsLogoutConfirmMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SessionCubit>().logout();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.settingsLogout),
            ),
          ],
        );
      },
    );
  }
}
