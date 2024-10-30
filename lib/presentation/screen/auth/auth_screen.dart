import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Импортируем библиотеку
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  // Используем MaskeTextController для телефонного номера
  final MaskedTextController phoneController = MaskedTextController(
    mask: '+0 (000) 000-0000', // Укажите необходимую маску
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
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
                      if (_isValidPhoneNumber(phoneNumber)) {
                        context.go('/sms/$phoneNumber');
                      } else {
                        _showError(
                            context, 'Invalid phone number: $phoneNumber');
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
                      if (phoneNumber.isNotEmpty) {
                        // Логика для входа
                      }
                      context.go('/dashboard');
                    },
                  ),
                ),
                const SizedBox(width: 64),
              ],
            ),
            const Spacer(),
            const Align(
                alignment: Alignment.bottomCenter,
                child: Text("Terms of Use | Contact support")),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    // Проверьте длину после удаления нецифровых символов
    return phoneNumber.length == 17; // Например, для маски (000) 000-0000
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
