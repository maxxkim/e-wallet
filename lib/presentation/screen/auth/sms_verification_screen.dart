import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class SmsVerificationScreen extends StatelessWidget {
  const SmsVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthCubit>(
      future: _createAuthCubit(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 64),
                          Center(
                            child: Text(
                              "We've sent a verification\n code to",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              "+66 (119) 345 87 90",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (var i = 0; i < 4; i++)
                                Padding(
                                  padding: EdgeInsets.only(right: i < 3 ? 12 : 0),
                                  child: Container(
                                    height: 56,
                                    width: 56,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Theme.of(context).primaryColor),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Can't receive a\nverification code",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 24),
                              SvgPicture.asset(
                                'assets/images/zippy_logo.svg',
                                semanticsLabel: 'Zippy Motto',
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                "I agree to Terms of Use",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Text(
                              "You will be redirected to Truora\nverification platform",
                              style: Theme.of(context).textTheme.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: RectangularButton(
                              label: "Go",
                              onPressed: () {
                                context.go('/');
                              },
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox(); // Return an empty widget if the state does not match
              },
            ),
          );
        }
        return const SizedBox(); // Return an empty widget if FutureBuilder has no data
      },
    );
  }

  Future<AuthCubit> _createAuthCubit(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final cubit = await AuthCubit.create(authRepository);
    return cubit;
  }
}