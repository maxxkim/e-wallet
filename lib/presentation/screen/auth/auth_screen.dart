import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final MaskedTextController phoneController = MaskedTextController(
    mask: '+7 967 055 3338',
    //mask: '+380 000 000 000',
    text: '+7 967 055 3338',
    //text: '+380 505 018 036',
  );

  String _formatPhoneForApi(String phone) {
    return phone.replaceAll(' ', '');
  }

  bool _isValidChileanPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleanPhone.length == 12 &&
        cleanPhone.startsWith('+56') &&
        cleanPhone[3] == '9';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 72),
              SvgPicture.asset(
                width: 256,
                'assets/images/zentro_logo.svg',
                semanticsLabel: 'Zentro Logo',
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(width: 72),
                  Text("Simple"),
                  Spacer(),
                  Text("Fast"),
                  Spacer(),
                  Text("Secure"),
                  SizedBox(width: 72),
                ],
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
              const SizedBox(height: 32),
              AuthTextField(
                label: l10n.mobileNumberLabel,
                switchValue: !context.watch<ThemeCubit>().isDarkMode,
                onSwitchChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                controller: phoneController,
              ).animate().slideX(
                    begin: -1,
                    end: 0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuad,
                  ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 64),
                  Expanded(
                    child: RectangularButton(
                      label: l10n.signUpButton,
                      onPressed: () {
                        final phoneNumber = phoneController.text.trim();
                        if (_isValidChileanPhone(phoneNumber) ||
                            phoneNumber == "+380 505 018 036" ||
                            phoneNumber == "+7 967 055 3338") {
                          final formattedPhone =
                              _formatPhoneForApi(phoneNumber);
                          context.go('/sms/$formattedPhone');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invalidPhoneError),
                            ),
                          );
                        }
                      },
                    ),
                  ).animate().slideY(
                        begin: 1,
                        end: 0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButtonCustom(
                      label: l10n.signInButton,
                      onPressed: () {
                        final phoneNumber = phoneController.text.trim();
                        if (_isValidChileanPhone(phoneNumber)) {
                          context.go('/dashboard');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invalidPhoneError),
                            ),
                          );
                        }
                      },
                    ),
                  ).animate().slideY(
                        begin: -1,
                        end: 0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 132),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(l10n.termsAndSupport),
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
            ],
          ),
        ),
      ),
    );
  }
}
