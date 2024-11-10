import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class SmsVerificationScreen extends StatelessWidget with FadeInAnimationMixin {
  final String phoneNumber;

  SmsVerificationScreen({Key? key, required this.phoneNumber})
      : super(key: key);

  final List<String> _verificationCode = ['', '', '', ''];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthCubit>(
      future: _createAuthCubit(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          )));
        } else if (snapshot.hasError) {
          return ErrorScreen(errorMessage: 'Error: ${snapshot.error}');
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
                    body: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: staggeredFadeIn([
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
                                phoneNumber,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            const SizedBox(height: 40),
                            _buildVerificationFields(context, state),
                            const SizedBox(height: 40),
                            fadeIn(
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Can't receive a\nverification code",
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 24),
                                  SvgPicture.asset(
                                    'assets/images/zippy_logo.svg',
                                    semanticsLabel: 'Zippy Motto',
                                  ),
                                ],
                              ),
                              delay: 300,
                            ),
                            const SizedBox(height: 128),
                            _buildTermsSection(context, state),
                            const SizedBox(height: 16),
                            fadeIn(
                              Center(
                                child: Text(
                                  "You will be redirected to Truora\nverification platform",
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              delay: 400,
                            ),
                            const SizedBox(height: 16),
                            fadeIn(
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 40),
                                child: RectangularButton(
                                  label: "Go",
                                  onPressed: state.termsAccepted &&
                                          state.codeStatus == CodeStatus.correct
                                      ? () {
                                          context.go('/dashboard');
                                        }
                                      : null,
                                  color: state.termsAccepted &&
                                          state.codeStatus == CodeStatus.correct
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                                ),
                              ),
                              delay: 500,
                            ),
                            const SizedBox(height: 40),
                          ]),
                        ),
                      ),
                    ),
                  );
                }
                return const ErrorScreen(
                  errorMessage:
                      'Verification code is not sent. We are working on this issue. Please try again later.',
                );
              },
            ),
          );
        }
        return const ErrorScreen(
          errorMessage:
              'Verification code is not sent. We are working on this issue. Please try again later.',
        );
      },
    );
  }

  Widget _buildVerificationFields(BuildContext context, AuthStateLoaded state) {
    if (state.codeStatus == CodeStatus.none) {
      return fadeIn(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              List.generate(4, (i) => _buildInputField(context, state, i)),
        ),
        delay: 200,
      );
    } else if (state.codeStatus == CodeStatus.invalid && state.shakeKey) {
      return Animate(
        effects: const [ShakeEffect(), FadeEffect()],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              List.generate(4, (i) => _buildInputField(context, state, i)),
        ),
      );
    } else if (state.codeStatus == CodeStatus.correct) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: fadeIn(
          SvgPicture.asset('assets/images/icon_tick.svg'),
          delay: 100,
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildInputField(
      BuildContext context, AuthStateLoaded state, int index) {
    return Padding(
      padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: getContainerColor(state.codeStatus, context),
          ),
        ),
        child: TextFormField(
          initialValue: _verificationCode[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) async {
            if (value.length == 1) {
              _verificationCode[index] = value;
              if (index < 3) {
                FocusScope.of(context).nextFocus();
              } else {
                if (state.shakeKey) {
                  context.read<AuthCubit>().restoreShake();
                }
                String code = _verificationCode.join('');
                await context.read<AuthCubit>().verifyCode(code);
                await context.read<SessionCubit>().checkAuthentication();
              }
            } else if (value.isEmpty && index > 0) {
              _verificationCode[index] = '';
              FocusScope.of(context).previousFocus();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTermsSection(BuildContext context, AuthStateLoaded state) {
    return fadeIn(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              context.read<SessionCubit>().checkAuthentication();
              context.read<AuthCubit>().toggleTerms();
            },
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  if (state.termsAccepted)
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          Text(
            "I agree to Terms of Use",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
      delay: 350,
    );
  }

  Future<AuthCubit> _createAuthCubit(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final cubit = await AuthCubit.create(authRepository, phoneNumber);
    return cubit;
  }

  Color getContainerColor(CodeStatus status, BuildContext context) {
    if (status == CodeStatus.correct) {
      return Theme.of(context).colorScheme.scrim;
    } else if (status == CodeStatus.invalid) {
      return Theme.of(context).colorScheme.error;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
