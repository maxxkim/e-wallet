import 'package:flutter/material.dart';

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus ?? false,
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
        hintText: hintText,
        errorText: errorText,
        prefixIcon: icon,
      ),
      style: const TextStyle(color: Colors.black, fontSize: 14),
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
    );
  }
}
