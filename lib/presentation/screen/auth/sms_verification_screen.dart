import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/state/auth/auth_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/auth/auth_cubit.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';

class SmsVerificationScreen extends StatelessWidget with FadeInAnimationMixin {
  final String phoneNumber;
  final String countryCode;
  final CountryModel? countryModel;

  const SmsVerificationScreen(
      {Key? key,
      required this.phoneNumber,
      required this.countryCode,
      this.countryModel})
      : super(key: key);

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
                            OTPVerificationCodeInput(
                              state: state,
                              onCompleted: (code) async {
                                await authCubit.verifyCode(code);
                                if (context.mounted) {
                                  final currentState = authCubit.state;
                                  if (currentState is AuthStateLoaded &&
                                      currentState.codeStatus ==
                                          CodeStatus.correct) {
                                    // Instead of just checking authentication and going to dashboard,
                                    // navigate to Truora verification screen first
                                    final userId = currentState.userId;
                                    final phone = currentState.phone;
                                    final authVerifyResponse =
                                        currentState.authVerifyResponse;
                                    context.go(
                                        '/sms/$phone/${countryCode ?? "CL"}/truora-verification',
                                        extra: {
                                          'userId': userId,
                                          'phoneNumber': phone,
                                          'authVerifyResponse':
                                              authVerifyResponse,
                                        });
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 40),
                            fadeIn(
                              Text(
                                l10n.smsVerificationCantReceive,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              delay: 300,
                            ),
                            const SizedBox(height: 32),
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

  Future<AuthCubit> _createAuthCubit(BuildContext context) async {
    final authRepository = RepositoryProvider.of<AuthRepository>(context);
    final cubit = await AuthCubit.create(
        authRepository, phoneNumber, countryCode,
        countryModel: countryModel);
    return cubit;
  }
}

class OTPVerificationCodeInput extends StatefulWidget {
  final AuthStateLoaded state;
  final Function(String) onCompleted;
  const OTPVerificationCodeInput({
    Key? key,
    required this.state,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<OTPVerificationCodeInput> createState() =>
      _OTPVerificationCodeInputState();
}

class _OTPVerificationCodeInputState extends State<OTPVerificationCodeInput>
    with FadeInAnimationMixin {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addListeners();
  }

  void _addListeners() {
    for (int i = 0; i < 4; i++) {
      _controllers[i].addListener(() {
        final text = _controllers[i].text;
        final numericOnly = text.replaceAll(RegExp(r'[^0-9]'), '');
        if (text != numericOnly) {
          _controllers[i].text = numericOnly;
          _controllers[i].selection = TextSelection.fromPosition(
              TextPosition(offset: numericOnly.length));
        }

        if (numericOnly.length == 1 && i < 3) {
          _focusNodes[i + 1].requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _checkComplete() {
    final code = _getCode();
    if (code.length == 4) {
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state.codeStatus == CodeStatus.none) {
      return fadeIn(
        _buildCodeInputs(),
        delay: 200,
      );
    } else if (widget.state.codeStatus == CodeStatus.invalid &&
        widget.state.shakeKey) {
      return Animate(
        effects: const [ShakeEffect(), FadeEffect()],
        child: _buildCodeInputs(),
      );
    } else if (widget.state.codeStatus == CodeStatus.correct) {
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

  Widget _buildCodeInputs() {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: (RawKeyEvent event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.backspace) {
            _handleBackspace();
          }
        }
      },
      child: Form(
        key: _form,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              List.generate(4, (index) => _buildInputField(context, index)),
        ),
      ),
    );
  }

  void _handleBackspace() {
    // Find the focused field
    int focusedIndex = -1;
    for (int i = 0; i < 4; i++) {
      if (_focusNodes[i].hasFocus) {
        focusedIndex = i;
        break;
      }
    }

    if (focusedIndex == -1) return;

    // If current field is empty and not the first field, move to previous
    if (_controllers[focusedIndex].text.isEmpty && focusedIndex > 0) {
      _focusNodes[focusedIndex - 1].requestFocus();
    }
  }

  Widget _buildInputField(BuildContext context, int index) {
    return Padding(
      padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: getContainerColor(widget.state.codeStatus, context),
            width: 1,
          ),
        ),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
          onChanged: (value) {
            if (value.length == 1 && index < 3) {
              _focusNodes[index + 1].requestFocus();
            }
            if (index == 3 && value.isNotEmpty) {
              _checkComplete();
            }
          },
          textInputAction:
              index < 3 ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _checkComplete();
            }
          },
        ),
      ),
    );
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
