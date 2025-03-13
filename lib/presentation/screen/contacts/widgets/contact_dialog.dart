import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';
import 'package:zippy/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/presentation/screen/auth/helpers/phone_mask_helper.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class ContactDialog extends StatefulWidget {
  final ContactModel? contact;
  const ContactDialog({this.contact, Key? key}) : super(key: key);

  @override
  ContactDialogState createState() => ContactDialogState();
}

class ContactDialogState extends State<ContactDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();
  String? _phoneError;
  String? _nameError;
  bool _isLoading = false;
  late MaskTextInputFormatter _phoneMaskFormatter;
  bool _isPhoneMaskLoaded = false;
  String? _phonePattern;

  @override
  void initState() {
    super.initState();

    // Initialize with a default formatter that allows any input
    _phoneMaskFormatter = MaskTextInputFormatter(
      mask: "+################################",
      filter: {"#": RegExp(r'[0-9]')},
    );

    // Set initial phone value
    if (widget.contact?.name != null) {
      final phoneNumber = widget.contact!.name;
      if (phoneNumber.startsWith('+')) {
        _phoneController = TextEditingController(text: phoneNumber);
      } else {
        _phoneController = TextEditingController(text: "+$phoneNumber");
      }
    } else {
      _phoneController = TextEditingController(text: "+");
    }

    _nameController = TextEditingController(text: widget.contact?.nickname);

    // Load the saved phone mask
    _loadPhoneMask();
  }

  Future<void> _loadPhoneMask() async {
    try {
      final formatter = await PhoneMaskHelper.getMaskFormatter();
      final pattern = await PhoneMaskHelper.getPhonePattern();

      if (mounted) {
        setState(() {
          _phoneMaskFormatter = formatter;
          _phonePattern = pattern;
          _isPhoneMaskLoaded = true;

          // Reformat the phone number with the loaded mask if available
          if (_phoneController.text.isNotEmpty) {
            // Preserve the current text
            final currentText = _phoneController.text;
            // Clean it and apply formatting
            final cleanPhone = currentText.replaceAll(RegExp(r'[^0-9+]'), '');
            if (cleanPhone.startsWith('+')) {
              // Apply the mask without changing the underlying value
              _phoneController.value = TextEditingValue(
                text: _phoneMaskFormatter.maskText(cleanPhone),
                selection: TextSelection.collapsed(
                    offset: _phoneMaskFormatter.maskText(cleanPhone).length),
              );
            }
          }
        });
      }
    } catch (e) {
      print("Error loading phone mask: $e");
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty || value == "+") {
      return 'Phone number is required';
    }

    // Clean the phone number for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^0-9+]'), '');

    // Use the saved phone pattern if available
    if (_phonePattern != null) {
      final phoneRegex = RegExp(_phonePattern!);
      if (!phoneRegex.hasMatch(cleanPhone)) {
        return 'Please enter a valid phone number';
      }
    } else {
      // Fallback pattern
      final phoneRegex = RegExp(r'^\+[\d]{8,}$');
      if (!phoneRegex.hasMatch(cleanPhone)) {
        return 'Please enter a valid phone number';
      }
    }

    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  void _validateAndSubmit() async {
    if (_isLoading) return;

    setState(() {
      _phoneError = null;
      _nameError = null;
      _isLoading = true;
    });

    // Get the clean phone number for validation and submission
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^0-9+]'), '');

    final phoneError = _validatePhone(cleanPhone);
    final nameError = _validateName(_nameController.text);

    if (phoneError != null || nameError != null) {
      setState(() {
        _phoneError = phoneError;
        _nameError = nameError;
        _isLoading = false;
      });
      return;
    }

    try {
      final contactsCubit = context.read<ContactsCubit>();
      if (widget.contact == null) {
        await contactsCubit.addContact(
          cleanPhone,
          _nameController.text.isEmpty ? null : _nameController.text,
        );
      } else {
        await contactsCubit.updateContact(
          cleanPhone,
          _nameController.text.isEmpty ? null : _nameController.text,
        );
      }

      if (mounted) {
        if (contactsCubit.lastMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(contactsCubit.lastMessage!)),
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
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
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<ContactsCubit, ContactsState>(
      listener: (context, state) {
        if (state is ContactsStateLoaded) {
          final message = context.read<ContactsCubit>().lastMessage;
          if (message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
            context.read<ContactsCubit>().lastMessage = null;
          }
          Navigator.of(context).pop(true);
        }
      },
      child: AlertDialog(
        title: Text(
          widget.contact == null ? l10n.contactsAddNew : l10n.contactsEdit,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _phoneController,
                enabled: !_isLoading,
                inputFormatters: [_phoneMaskFormatter],
                decoration: InputDecoration(
                  labelText: l10n.contactsPhone,
                  errorText: _phoneError,
                  prefixIcon: const Icon(Icons.phone),
                  hintText: _isPhoneMaskLoaded
                      ? _phoneMaskFormatter.getMask()
                      : "+ (123) 456 78 90",
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: l10n.contactsName,
                  errorText: _nameError,
                  prefixIcon: const Icon(Icons.person),
                ),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        actions: [
          RectangularButton(
            label: _isLoading ? 'Saving...' : l10n.contactsSave,
            onPressed: _isLoading ? null : _validateAndSubmit,
          ),
        ],
      ),
    );
  }
}
