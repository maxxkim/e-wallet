import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class SmsVerificationScreen extends StatelessWidget with FadeInAnimationMixin {
  final String phoneNumber;
  final String countryCode;
  SmsVerificationScreen(
      {Key? key, required this.phoneNumber, required this.countryCode})
      : super(key: key);

  final List<String> _verificationCode = ['', '', '', ''];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: staggeredFadeIn([
                            const SizedBox(height: 64),
                            Center(
                              child: Text(
                                l10n.smsVerificationSent,
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
                              Text(
                                l10n.smsVerificationCantReceive,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              delay: 300,
                            ),
                            const SizedBox(height: 184),
                            /*_buildTermsSection(context, state, l10n),
                            const SizedBox(height: 16),*/
                            fadeIn(
                              Center(
                                child: Text(
                                  l10n.smsVerificationTruoraRedirect,
                                  style: Theme.of(context).textTheme.bodyMedium,
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
                                  label: l10n.continueButton,
                                  onPressed: state.termsAccepted &&
                                          state.codeStatus == CodeStatus.correct
                                      ? () {
                                          context.go('/dashboard');
                                        }
                                      : null,
                                ),
                              ),
                              delay: 500,
                            ),
                          ]),
                        ),
                      ),
                    ),
                  );
                }
                return ErrorScreen(
                  errorMessage: l10n.smsVerificationError,
                );
              },
            ),
          );
        }
        return ErrorScreen(
          errorMessage: l10n.smsVerificationError,
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
            width: 1,
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
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
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

  Widget _buildTermsSection(
      BuildContext context, AuthStateLoaded state, AppLocalizations l10n) {
    return fadeIn(
      Wrap(
        // Changed from Row to Wrap
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16, // Horizontal spacing
        runSpacing: 8, // Vertical spacing between lines
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
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                  color: getContainerColor(state.codeStatus, context),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  if (state.termsAccepted)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Wrap(
            // Use another Wrap for the text part
            children: [
              Text(
                l10n.iAgree,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                l10n.termsOfUse,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      delay: 350,
    );
  }

  Future<AuthCubit> _createAuthCubit(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final cubit =
        await AuthCubit.create(authRepository, phoneNumber, countryCode);
    return cubit;
  }

  Color getContainerColor(CodeStatus status, BuildContext context) {
    if (status == CodeStatus.correct) {
      return Theme.of(context).colorScheme.scrim;
    } else if (status == CodeStatus.invalid) {
      return Theme.of(context).colorScheme.error;
    } else {
      return Theme.of(context).colorScheme.secondary;
    }
  }
}
