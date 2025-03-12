import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool? autofocus;
  final Widget? icon;
  final TextInputType keyboardType;
  final FormFieldValidator? validator;
  final bool? enabled;
  final String? errorText;
  final bool isPhoneInput;
  final MaskTextInputFormatter? maskFormatter;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.validator,
    this.labelText,
    this.autofocus,
    this.hintText,
    this.icon,
    this.enabled,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.isPhoneInput = false,
    this.maskFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Default phone formatter with + prefix if none provided
    final phoneFormatter = maskFormatter ??
        MaskTextInputFormatter(
          mask: "+# (###) ### ## ##",
          filter: {"#": RegExp(r'[0-9]')},
        );

    return TextFormField(
      controller: controller,
      autofocus: autofocus ?? false,
      inputFormatters: isPhoneInput ? [phoneFormatter] : null,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        floatingLabelStyle: const TextStyle(color: Colors.black, fontSize: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
        ),
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.0,
          ),
        ),
        labelText: labelText,
        hintText: isPhoneInput ? "+1 (234) 567 89 00" : hintText,
        errorText: errorText,
        prefixIcon: icon ??
            (isPhoneInput
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      "+",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null),
        prefixIconConstraints: isPhoneInput && icon == null
            ? const BoxConstraints(minWidth: 0, minHeight: 0)
            : null,
      ),
      style: const TextStyle(color: Colors.black, fontSize: 14),
      keyboardType: isPhoneInput ? TextInputType.phone : keyboardType,
      enabled: enabled,
      validator: validator,
    );
  }
}
