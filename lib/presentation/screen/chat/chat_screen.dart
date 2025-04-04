import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/edge_tier_chat.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({Key? key}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen>
    with FadeInAnimationMixin {
  final LoggerService _logger = LoggerService();
  final GlobalKey<EdgeTierChatWidgetState> _edgeTierKey =
      GlobalKey<EdgeTierChatWidgetState>();
  bool _isChatAvailable = false;
  String _userName = "";
  String _userEmail = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logger.kawaii('✧･ﾟ: *✧･ﾟ Support Chat Screen initialized! *:･ﾟ✧*:･ﾟ✧');
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Future placeholder for actual user info API call
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _userName = "Zentro User";
        _userEmail = "user@zentrowallet.com";
        _isLoading = false;
      });
    } catch (e) {
      _logger.error('❌ Error loading user information: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleChatAvailabilityChanged(bool isAvailable) {
    _logger.info('🎯 Chat availability changed to: $isAvailable');
    setState(() {
      _isChatAvailable = isAvailable;
    });
  }

  void _handleChatOpened() {
    _logger.kawaii('🎉 Chat window opened successfully! ヽ(*・ω・)ﾉ');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.supportChatOpened),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }

  Future<void> _openChat() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final chatWidget = _edgeTierKey.currentState;
      if (chatWidget != null) {
        await chatWidget.storeVariable(1, _userName);
        await chatWidget.storeVariable(2, _userEmail);
        await chatWidget.setOptions(
            hideMinimiseButton: false, hideCloseButton: false);
        await chatWidget.openChat();
      }
    } catch (e) {
      _logger.error('❌ Error opening chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.supportChatError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: fadeIn(Text(l10n.supportTitle)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: staggeredFadeIn([
                    const SizedBox(height: 16),
                    fadeInFromTop(
                      Text(
                        l10n.supportChatTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    fadeIn(
                      Text(
                        l10n.supportChatDescription,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      delay: 100,
                    ),
                    const SizedBox(height: 24),
                    fadeIn(
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.supportChatInfo,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoItem(
                                context,
                                Icons.people,
                                l10n.supportAgentsTitle,
                                l10n.supportAgentsDescription),
                            const SizedBox(height: 12),
                            _buildInfoItem(
                                context,
                                Icons.schedule,
                                l10n.supportHoursTitle,
                                l10n.supportHoursDescription),
                            const SizedBox(height: 12),
                            _buildInfoItem(
                                context,
                                Icons.security,
                                l10n.supportSecurityTitle,
                                l10n.supportSecurityDescription),
                          ],
                        ),
                      ),
                      delay: 200,
                    ),
                    const SizedBox(height: 24),
                    fadeIn(
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _isChatAvailable
                                  ? l10n.supportChatAvailable
                                  : l10n.supportChatUnavailable,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: _isChatAvailable
                                        ? Theme.of(context).colorScheme.scrim
                                        : Theme.of(context).colorScheme.error,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            RectangularButton(
                              label: _isLoading
                                  ? l10n.supportChatLoading
                                  : l10n.supportChatStartButton,
                              onPressed: (_isChatAvailable && !_isLoading)
                                  ? _openChat
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      delay: 300,
                    ),
                    const SizedBox(height: 24),
                    fadeIn(
                      SizedBox(
                        height: 1,
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: Theme.of(context)
                                .extension<ThemeGradients>()
                                ?.darkBlueGradient,
                          ),
                        ),
                      ),
                      delay: 400,
                    ),
                    const SizedBox(height: 24),
                    fadeIn(
                      Text(
                        l10n.supportAlternativeTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      delay: 500,
                    ),
                    const SizedBox(height: 16),
                    fadeIn(
                      _buildAlternativeContactCard(
                        context,
                        Icons.email,
                        l10n.supportEmailTitle,
                        l10n.supportEmailDescription,
                        'support@zentrowallet.com',
                      ),
                      delay: 600,
                    ),
                    const SizedBox(height: 12),
                    fadeIn(
                      _buildAlternativeContactCard(
                        context,
                        Icons.phone,
                        l10n.supportPhoneTitle,
                        l10n.supportPhoneDescription,
                        '+1 (555) 123-4567',
                      ),
                      delay: 700,
                    ),

                    // Hidden EdgeTier chat widget that serves as the actual interface
                    SizedBox(
                      height: 1,
                      width: 1,
                      child: EdgeTierChatWidget(
                        key: _edgeTierKey,
                        setupId: 'zentro-wallet-support',
                        companyIdentifier: 'ZENTRO',
                        usePreProd: false,
                        onAvailabilityChanged: _handleChatAvailabilityChanged,
                        onChatOpened: _handleChatOpened,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          const CustomBottomNavBar(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeContactCard(BuildContext context, IconData icon,
      String title, String description, String contactInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  contactInfo,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
