import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/internal/services/logger_service.dart';
import 'package:zippy/presentation/bloc/topUp/top_up_cubit.dart';
import 'package:zippy/presentation/bloc/withdrawal/withdrawal_cubit.dart';
import 'package:zippy/domain/state/topUp/top_up_state.dart';
import 'package:zippy/domain/state/withdrawal/withdrawal_state.dart';
import 'package:zippy/presentation/screen/topUp/widgets/enum_parameter_input_field.dart';
import 'package:zippy/presentation/screen/topUp/widgets/provider_parameter_inpuit_field.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class ProviderCard extends StatefulWidget {
  final Provider provider;
  final Future<void> Function(Map<String, dynamic> data, GoRouter router)
      onSubmit;
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

  List<Parameter> get _validParameters =>
      widget.provider.parameters?.where((param) => param != null).toList() ??
      [];

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

    // Initialize controllers for each parameter
    for (var param in _validParameters) {
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

  Future<void> _handleSubmit() async {
    if (_isLoading) return;
    final l10n = AppLocalizations.of(context)!;

    // Validate all fields
    bool isValid = true;
    setState(() {
      for (var param in _validParameters) {
        final value = _controllers[param.name]?.text;
        final error = _validateField(param, value);
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
      // Build request body
      final Map<String, dynamic> body = {};
      for (var param in _validParameters) {
        // Special handling for amount field: strip all non-digit characters
        if (param.name == 'amount') {
          // Remove all non-digit characters
          final rawValue = _controllers[param.name]?.text ?? '';
          final digitsOnly = rawValue.replaceAll(RegExp(r'[^\d]'), '');
          body[param.name] = digitsOnly;
        } else {
          body[param.name] = _controllers[param.name]?.text ?? '';
        }
      }
      body['provider'] = widget.provider.name;
      final router = GoRouter.of(context);
      await widget.onSubmit(body, router);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.operationError(e.toString()))),
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

  String? _validateField(Parameter param, String? value) {
    if (value == null || value.isEmpty) {
      if (param.required == "true") {
        return param.description?.error ?? "Este campo es obligatorio";
      }
      return null;
    }

    // Validate field length
    if (param.min != null && value.length < int.parse(param.min!)) {
      return param.description?.error ?? "El valor es demasiado corto";
    }

    if (param.max != null && value.length > int.parse(param.max!)) {
      return param.description?.error ?? "El valor es demasiado largo";
    }

    // Validate against regex pattern if provided
    if (param.pattern != null && param.pattern!.isNotEmpty) {
      final RegExp regex = RegExp(param.pattern!);
      if (!regex.hasMatch(value)) {
        return param.description?.error ?? "Formato inválido";
      }
    }

    return null;
  }

  Widget _buildParameterInput(Parameter param) {
    // For enum parameters (dropdown selections)
    if (param.enumValues != null && param.enumValues!.isNotEmpty) {
      return EnumParameterInputField(
        parameter: param,
        controller: _controllers[param.name]!,
        errorText: _errors[param.name],
        enabled: !_isLoading,
        onChanged: (value) {
          setState(() {
            _errors[param.name] = _validateField(param, value);
          });
        },
      );
    } else {
      // For text input parameters
      return ParameterInputField(
        parameter: param,
        controller: _controllers[param.name]!,
        errorText: _errors[param.name],
        enabled: !_isLoading,
        onChanged: (value) {
          setState(() {
            _errors[param.name] = _validateField(param, value);
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_validParameters.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          _buildHeader(),
          _buildExpandedContent(l10n),
        ],
      ),
    );

    return _wrapWithListener(content);
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpand,
      child: Container(
        height: 64.0,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border.all(
            color: _isExpanded
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
            bottom: Radius.circular(16),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: [
              if (widget.provider.logo != null &&
                  widget.provider.logo!.isNotEmpty)
                Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 12),
                  child: SvgPicture.string(widget.provider.logo!),
                ),
              Expanded(
                child: Column(
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
              ),
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandedContent(AppLocalizations l10n) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: SizeTransition(
        sizeFactor: _expandAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.vertical(
              top: _isExpanded ? Radius.zero : const Radius.circular(16),
              bottom: const Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _validParameters.map((param) {
                  bool isLastParam = _validParameters.last == param;
                  return _buildParameterRow(param, isLastParam, l10n);
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParameterRow(
      Parameter param, bool isLastParam, AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLastParam ? 0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildParameterInput(param),
          if (isLastParam) ...[
            const SizedBox(height: 16),
            _buildSubmitButton(l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(AppLocalizations l10n) {
    return FilledButton(
      onPressed: _isLoading ? null : _handleSubmit,
      style: ButtonStyle(
        padding:
            WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 24)),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
      ),
      child: Container(
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:
              Theme.of(context).extension<ThemeGradients>()?.darkBlueGradient,
          borderRadius: BorderRadius.circular(32),
        ),
        child: _isLoading
            ? Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  l10n.continueButton,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
      ),
    );
  }

  Widget _wrapWithListener(Widget content) {
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
    }

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
