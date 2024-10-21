import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final TextEditingController phoneController = TextEditingController(text: "+1 111 111 11 11");

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthCubit>(
      future: _createAuthCubit(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Возвращаем ErrorScreen при возникновении ошибки
          return ErrorScreen(errorMessage: 'Ошибка: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final authCubit = snapshot.data!;
          return BlocProvider.value(
            value: authCubit,
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthStateLoaded) {
                  return Scaffold(
                    resizeToAvoidBottomInset: true,
                    appBar: AppBar(backgroundColor: Colors.transparent),
                    body: Padding(
                      padding: const EdgeInsets.all(24),
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) {
                          if (state is AuthStateError) {
                          }
                        },
                        builder: (context, state) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(height: 72),
                              SvgPicture.asset(
                                'assets/images/zippy_pay_logo.svg',
                                semanticsLabel: 'Zippy Pay Logo'
                              ),
                              const SizedBox(height: 40),
                              SvgPicture.asset(
                                'assets/images/zippy_motto.svg',
                                semanticsLabel: 'Zippy Motto'
                              ),
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
                                          showDialog<void>(
                                            context: context,
                                            builder: (context) {
                                              return ScreenLock(
                                                correctString: '1234',
                                                onCancelled: Navigator.of(context).pop,
                                                onUnlocked: () => context.go('/sms'),
                                              );
                                            },
                                          );
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
                              const Align(alignment: Alignment.bottomCenter, child: Text("Terms of Use | Contact support")),
                              const SizedBox(height: 40),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }
                return const SizedBox(); // возвращаем пустой виджет, если состояние не соответствует
              },
            ),
          );
        }
        return const SizedBox(); // возвращаем пустой виджет, если нет данных
      },
    );
  }

  Future<AuthCubit> _createAuthCubit(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final cubit = await AuthCubit.create(authRepository);
    return cubit;
  }
}