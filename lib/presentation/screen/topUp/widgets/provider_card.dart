import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/presentation/bloc/topUp/top_up_cubit.dart';
import 'package:zippy/presentation/bloc/withdrawal/withdrawal_cubit.dart';
import 'package:zippy/domain/state/topUp/top_up_state.dart';
import 'package:zippy/domain/state/withdrawal/withdrawal_state.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class ProviderCard extends StatefulWidget {
  final Provider provider;
  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final bool isWithdrawal;

  const ProviderCard({
    Key? key,
    required this.provider,
    required this.onSubmit,
    this.isWithdrawal = false,
  }) : super(key: key);

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  bool _isLoading = false;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _errors = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    for (var param in widget.provider.parameters) {
      _controllers[param.name] = TextEditingController();
      _errors[param.name] = null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  String? _validateField(Parameter param, String? value) {
    if (value == null || value.isEmpty) {
      if (param.required == "true") {
        return param.description?.error ?? 'This field is required';
      }
      return null;
    }

    if (param.type == "number") {
      final number = double.tryParse(value);
      if (number == null) {
        return 'Please enter a valid number';
      }
      if (param.min != null && number < double.parse(param.min!)) {
        return 'Value must be greater than ${param.min}';
      }
      if (param.max != null && number > double.parse(param.max!)) {
        return 'Value must be less than ${param.max}';
      }
    }

    if (param.pattern != null) {
      final regex = RegExp(param.pattern!);
      if (!regex.hasMatch(value)) {
        return param.description?.error ?? 'Invalid format';
      }
    }

    return null;
  }

  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    bool isValid = true;
    setState(() {
      for (var param in widget.provider.parameters) {
        final error = _validateField(param, _controllers[param.name]?.text);
        _errors[param.name] = error;
        if (error != null) {
          isValid = false;
        }
      }
    });

    if (!isValid) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> body = {};
      for (var param in widget.provider.parameters) {
        body[param.name] = _controllers[param.name]?.text ?? '';
      }

      body['providerId'] = widget.provider.id;

      await widget.onSubmit(body);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
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
    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Container(
              height: 64.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(
                    color: _isExpanded
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary),
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    if (widget.provider.logo != null)
                      SvgPicture.string(widget.provider.logo!),
                    const Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.title ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          widget.provider.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    RotationTransition(
                      turns:
                          Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.vertical(
                    top: _isExpanded ? Radius.zero : Radius.circular(16),
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: widget.provider.parameters.map((param) {
                        bool isLastParam =
                            widget.provider.parameters.last == param;
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: isLastParam ? 0 : 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _controllers[param.name]!,
                                  labelText:
                                      param.description?.label ?? param.name,
                                  hintText: param.description?.placeholder,
                                  keyboardType: _getKeyboardType(param.type),
                                  enabled: !_isLoading,
                                  errorText: _errors[param.name],
                                  validator: (value) =>
                                      _validateField(param, value),
                                ),
                              ),
                              if (isLastParam) ...[
                                const SizedBox(width: 16),
                                FilledButton(
                                  onPressed: _isLoading ? null : _handleSubmit,
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          horizontal: 24),
                                    ),
                                    backgroundColor: WidgetStateProperty.all(
                                        Colors.transparent),
                                  ),
                                  child: Container(
                                    height: 40,
                                    width: 96,
                                    decoration: BoxDecoration(
                                      gradient: Theme.of(context)
                                          .extension<ThemeGradients>()
                                          ?.darkBlueGradient,
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              'Continue',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displaySmall,
                                            ),
                                          ),
                                  ),
                                )
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isWithdrawal) {
      return BlocListener<WithdrawalCubit, WithdrawalState>(
        listener: (context, state) {
          if (state is WithdrawalStateInitiated) {
            launchUrl(Uri.parse(state.url));
          } else if (state is WithdrawalStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: content,
      );
    } else {
      return BlocListener<TopUpCubit, TopUpState>(
        listener: (context, state) {
          if (state is TopUpStateInitiated) {
            launchUrl(Uri.parse(state.url));
          } else if (state is TopUpStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        child: content,
      );
    }
  }

  TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}
