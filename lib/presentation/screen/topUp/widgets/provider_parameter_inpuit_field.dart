import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';
import 'package:zippy/presentation/screen/topUp/helpers/parameter_mask_formatter.dart';

class ParameterInputField extends StatefulWidget {
  final Parameter parameter;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool enabled;
  final String? errorText;

  const ParameterInputField({
    Key? key,
    required this.parameter,
    required this.controller,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  State<ParameterInputField> createState() => _ParameterInputFieldState();
}

class _ParameterInputFieldState extends State<ParameterInputField> {
  TextInputFormatter? _formatter;
  String? _hintText;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _formatter = ParameterMaskFormatter.getFormatter(widget.parameter);
    _hintText = ParameterMaskFormatter.getHint(widget.parameter);
    _errorText = widget.errorText;

    // Pre-format the input if needed
    if (_formatter != null && widget.controller.text.isNotEmpty) {
      final formattedValue = _formatter!.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: widget.controller.text),
      );

      if (formattedValue.text != widget.controller.text) {
        widget.controller.text = formattedValue.text;
      }
    }
  }

  @override
  void didUpdateWidget(ParameterInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }

    if (oldWidget.parameter != widget.parameter) {
      _formatter = ParameterMaskFormatter.getFormatter(widget.parameter);
      _hintText = ParameterMaskFormatter.getHint(widget.parameter);
    }
  }

  TextInputType _getKeyboardType() {
    switch (widget.parameter.type.toLowerCase()) {
      case 'number':
      case 'string' when widget.parameter.pattern?.contains(r'\d') ?? false:
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.parameter.description?.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              widget.parameter.description!.label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        TextField(
          controller: widget.controller,
          inputFormatters: _formatter != null ? [_formatter!] : null,
          decoration: InputDecoration(
            hintText: _hintText,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          ),
          keyboardType: _getKeyboardType(),
          enabled: widget.enabled,
          onChanged: (value) {
            setState(() {
              _errorText =
                  ParameterMaskFormatter.validateValue(value, widget.parameter);
            });
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
        ),
      ],
    );
  }
}
