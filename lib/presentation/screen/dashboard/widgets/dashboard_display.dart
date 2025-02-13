import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class BalanceDisplay extends StatefulWidget {
  final num? balance;
  final String currency = "CLP";
  final DashboardTranslations translations;

  BalanceDisplay({super.key, this.balance, required this.translations});

  @override
  State<BalanceDisplay> createState() => _BalanceDisplayState();
}

class _BalanceDisplayState extends State<BalanceDisplay>
    with FadeInAnimationMixin {
  bool _isUpdating = false;
  bool _isLoggingOut = false;

  static final Map<String, IconData> currencyIcons = {
    'clp': MdiIcons.currencyUsd,
    'ars': MdiIcons.currencyUsd,
    'brl': MdiIcons.currencyBrl,
    'pen': MdiIcons.currencyUsd,
    'usd': MdiIcons.currencyUsd,
    'eur': MdiIcons.currencyEur,
    'gbp': MdiIcons.currencyGbp,
    'btc': MdiIcons.currencyBtc,
    'eth': MdiIcons.currencyEth,
    'usdt': MdiIcons.currencyUsd,
  };

  IconData _getCurrencyIcon(String currencyCode) {
    return currencyIcons[currencyCode.toLowerCase()] ?? MdiIcons.currencyUsd;
  }

  Future<void> _updateBalance(BuildContext context) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await context.read<DashboardCubit>().loadData();
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await context.read<SessionCubit>().logout();
      if (mounted) {
        context.read<DashboardCubit>().reset();
      }
    } catch (e) {
      print(e);
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardStateLoggedOut && mounted) {
          GoRouter.of(context).go('/');
        }
      },
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Row(
            children: [
              Expanded(
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: Theme.of(context)
                              .extension<ThemeGradients>()
                              ?.deepBlueGradient
                              .colors ??
                          [],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: deepBlueColor,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 24, top: 16, bottom: 16, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getCurrencyIcon(widget.currency),
                                  size: 32,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 8.0),
                                Text(
                                  widget.balance?.toStringAsFixed(widget.balance
                                                  ?.toString()
                                                  .contains('.') ??
                                              false
                                          ? 2
                                          : 0) ??
                                      '0',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                ),
                                const Spacer(),
                                if (kDebugMode)
                                  IconButton(
                                    icon: _isLoggingOut
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : const Icon(Icons.exit_to_app),
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    onPressed: _isLoggingOut
                                        ? null
                                        : () => _handleLogout(context),
                                  ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: GestureDetector(
                                onTap: _isUpdating
                                    ? null
                                    : () => _updateBalance(context),
                                child: Row(
                                  children: [
                                    if (_isUpdating)
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white.withOpacity(0.7),
                                          ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.translations.totalBalance,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Align(
                        child: Container(
                          height: 56.0,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => context.go('/dashboard/topUp'),
                                child: Text(
                                  widget.translations.topUp,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    context.go('/dashboard/withdrawal'),
                                child: Text(
                                  widget.translations.withdraw,
                                  style:
                                      Theme.of(context).textTheme.displayMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 4),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/dashboard/scan'),
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/icon_qr.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.translations.scan,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => context.go('/dashboard/transfer'),
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/images/icon_transfer.svg',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.translations.transfer,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
