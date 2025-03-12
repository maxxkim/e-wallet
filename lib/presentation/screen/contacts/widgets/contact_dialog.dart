import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';
import 'package:zippy/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class ContactDialog extends StatefulWidget {
  final ContactModel? contact;
  const ContactDialog({this.contact});

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

  @override
  void initState() {
    super.initState();
    // Initialize phone mask formatter with +
    _phoneMaskFormatter = MaskTextInputFormatter(
        mask: "+######################",
        filter: {"#": RegExp(r'[0-9]')},
        initialText: widget.contact?.name);

    // If there's existing contact, try to apply the mask
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
    final phoneRegex = RegExp(r'^\+[\d\s\-\(\)]{8,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required ';
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
    final phoneError = _validatePhone(_phoneController.text);
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
      if (widget.contact == null) {
        await context.read<ContactsCubit>().addContact(
              _phoneController.text,
              _nameController.text.isEmpty ? null : _nameController.text,
            );
      } else {
        await context.read<ContactsCubit>().updateContact(
              _phoneController.text,
              _nameController.text.isEmpty ? null : _nameController.text,
            );
      }
      if (mounted) {
        Navigator.of(context).pop();
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
                  hintText: "+ (123) 456 78 90",
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
