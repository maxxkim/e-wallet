import 'package:flutter/material.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';

class EnumParameterInputField extends StatefulWidget {
  final Parameter parameter;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final bool enabled;
  final String? errorText;

  const EnumParameterInputField({
    Key? key,
    required this.parameter,
    required this.controller,
    this.onChanged,
    this.enabled = true,
    this.errorText,
  }) : super(key: key);

  @override
  State<EnumParameterInputField> createState() =>
      _EnumParameterInputFieldState();
}

class _EnumParameterInputFieldState extends State<EnumParameterInputField> {
  String? _selectedValue;
  String? _errorText;
  List<Map<String, String>> _options = [];

  @override
  void initState() {
    super.initState();
    _errorText = widget.errorText;
    _processEnumValues();

    // Initialize with existing value if present
    if (widget.controller.text.isNotEmpty) {
      _selectedValue = widget.controller.text;
    }
  }

  @override
  void didUpdateWidget(covariant EnumParameterInputField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.errorText != widget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
    }

    if (oldWidget.parameter.enumValues != widget.parameter.enumValues) {
      _processEnumValues();
    }
  }

  /// Process enum values from the parameter definition
  void _processEnumValues() {
    _options = [];
    final enumValues = widget.parameter.enumValues;

    if (enumValues == null || enumValues.isEmpty) return;

    for (var i = 0; i < enumValues.length; i++) {
      final item = enumValues[i];

      if (item is Map) {
        // Handle structured enum values (with id and name)
        String id = '';
        String name = '';

        if (item.containsKey('id')) {
          id = item['id'].toString();
        }

        if (item.containsKey('name')) {
          name = item['name'].toString();
        }

        _options.add({'id': id, 'name': name});
      } else {
        // Handle simple string enum values
        final stringValue = item.toString();
        _options.add({'id': stringValue, 'name': stringValue});
      }
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
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: widget.parameter.description?.placeholder ??
                'Seleccione una opción',
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            enabled: widget.enabled,
          ),
          value: _selectedValue,
          items: _options.map((option) {
            return DropdownMenuItem<String>(
              value: option['id'],
              child: Text(option['name'] ?? ''),
            );
          }).toList(),
          onChanged: widget.enabled
              ? (value) {
                  setState(() {
                    _selectedValue = value;
                    widget.controller.text = value ?? '';
                    _errorText = null;
                  });

                  if (widget.onChanged != null && value != null) {
                    widget.onChanged!(value);
                  }
                }
              : null,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).colorScheme.primary,
          ),
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
