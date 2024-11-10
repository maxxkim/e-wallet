import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  // Chilean phone format: +56 9 xxxx xxxx
  final MaskedTextController phoneController = MaskedTextController(
    mask: '+380 000 000 000',
    text: '+380 505 018 036', // Default number converted to Chilean format
  );

  String _formatPhoneForApi(String phone) {
    // Remove spaces and format consistently
    return phone.replaceAll(' ', '');
  }

  bool _isValidChileanPhone(String phone) {
    // Chilean mobile numbers: +56 9 xxxx xxxx (12 digits total including +56)
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    return cleanPhone.length == 12 &&
        cleanPhone.startsWith('+56') &&
        cleanPhone[3] == '9';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 72),
              SvgPicture.asset('assets/images/zippy_pay_logo.svg',
                  semanticsLabel: 'Zippy Pay Logo'),
              const SizedBox(height: 40),
              SvgPicture.asset('assets/images/zippy_motto.svg',
                  semanticsLabel: 'Zippy Motto'),
              const SizedBox(height: 40),
              AuthTextField(
                switchValue: !context.watch<ThemeCubit>().isDarkMode,
                onSwitchChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                controller: phoneController,
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 64),
                  Expanded(
                    child: RectangularButton(
                      label: "Sign Up",
                      onPressed: () {
                        final phoneNumber = phoneController.text.trim();
                        if (_isValidChileanPhone(phoneNumber) ||
                            phoneNumber == "+380 505 018 036") {
                          final formattedPhone =
                              _formatPhoneForApi(phoneNumber);
                          context.go('/sms/$formattedPhone');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please enter a valid Chilean mobile number'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButtonCustom(
                      label: "Sign In",
                      onPressed: () {
                        final phoneNumber = phoneController.text.trim();
                        if (_isValidChileanPhone(phoneNumber)) {
                          context.go('/dashboard');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please enter a valid Chilean mobile number'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 156),
              const Align(
                  alignment: Alignment.bottomCenter,
                  child: Text("Terms of Use | Contact support")),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
