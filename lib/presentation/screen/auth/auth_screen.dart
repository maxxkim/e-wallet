import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final TextEditingController phoneController = TextEditingController(text: "+1 111 111 11 11");

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(backgroundColor: Colors.transparent,),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: BlocProvider(
        create: (context) => AuthCubit(FirebaseAuth.instance),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message ?? 'Error')));
            }
            // Показываем диалоговое окно, если код подтверждения отправлен
            if (state is AuthCodeSent) {
              _showVerificationDialog(context);
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 72),
                SvgPicture.asset(
                  'assets/images/zippy_pay_logo.svg',
                  semanticsLabel: 'Acme Logo'
                ),
                const SizedBox(height: 40),
                SvgPicture.asset(
                  'assets/images/zippy_motto.svg',
                  semanticsLabel: 'Acme Logo'
                ),
                const SizedBox(height: 40),
                AuthTextField(
                  switchValue: !context.watch<ThemeCubit>().isDarkMode, // Получаем текущее состояние темы
                  onSwitchChanged: (value) {
                    context.read<ThemeCubit>().toggleTheme(); // Вызов метода переключения темы
                  },
                  controller: phoneController, // Передаем контроллер телефонного поля
                ),
                const SizedBox(height: 40),
                if (state is AuthLoading) 
                  const CircularProgressIndicator()
                else
                  Row(
                    children: [
                      const SizedBox(width: 64), // Add some spacing
                      Expanded( // Use Expanded to let the button take available space
                        child: RectangularButton(
                          label: "Sign Up",
                          onPressed: () {
                            showDialog<void>(
                            context: context,
                            builder: (context) {
                              return ScreenLock(
                                correctString: '1234',
                                onCancelled: Navigator.of(context).pop,
                                onUnlocked: Navigator.of(context).pop,
                              );
                            },
                          );
                          },
                        ),
                      ),
                      const SizedBox(width: 16), // Add some spacing
                      Expanded( // Similarly for Sign in
                        child: OutlinedButtonCustom(
                          label: "Sign In",
                          onPressed: () {
                            final phoneNumber = phoneController.text.trim();
                            if (phoneNumber.isNotEmpty) {
                              context.read<AuthCubit>().loginWithPhone(phoneNumber);
                            }
                            context.go('/dashboard');
                          },
                        ),
                      ),
                      const SizedBox(width: 64), // Add some spacing
                    ],
                  ),
                const Spacer(), // Добавляем Spacer для перемещения "Terms of Use" вниз
                const Align(alignment: Alignment.bottomCenter, child: Text("Terms of Use | Contact support")),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    ),
  );
}

  void _showVerificationDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Verification Code'),
          content: CustomTextField(
            controller: codeController,
            labelText: '6-Digit Code',
            hintText: 'Enter the 6-digit code sent to your phone',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final verificationCode = codeController.text.trim();
                if (verificationCode.length == 6) {
                  // Вставьте здесь вызов метода для проверки кода
                  // context.read<AuthCubit>().verifyCode(verificationCode);
                  context.go('/dashboard'); // Если вы хотите сразу перейти на экран после проверки кода
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid 6-digit code.')));
                }
              },
              child: const Text('Submit'),
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero
          ),
        );
      },
    );
  }
}