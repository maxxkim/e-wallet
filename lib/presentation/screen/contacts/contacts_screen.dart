// ./lib/presentation/screen/contacts/contacts_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';
import 'package:zippy/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard/transfer'),
        ),
        title: Text(
          'Contacts',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showContactDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ContactsCubit, ContactsState>(
        builder: (context, state) {
          if (state is ContactsStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ContactsStateError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<ContactsCubit>().loadContacts(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is ContactsStateLoaded) {
            return ListView.builder(
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final contact = state.contacts[index];
                return _ContactTile(
                  contact: contact,
                  onEdit: () => _showContactDialog(context, contact: contact),
                  onDelete: () => _showDeleteDialog(context, contact),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showContactDialog(BuildContext context, {ContactModel? contact}) {
    showDialog(
      context: context,
      builder: (context) => _ContactDialog(contact: contact),
    );
  }

  void _showDeleteDialog(BuildContext context, ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ContactsCubit>().deleteContact(contact.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(contact.name),
      subtitle: contact.nickname != null ? Text(contact.nickname!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _ContactDialog extends StatefulWidget {
  final ContactModel? contact;

  const _ContactDialog({this.contact});

  @override
  _ContactDialogState createState() => _ContactDialogState();
}

class _ContactDialogState extends State<_ContactDialog> {
  late TextEditingController _phoneController;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.contact?.name);
    _nameController = TextEditingController(text: widget.contact?.nickname);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name (Optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        RectangularButton(
          label: 'Save',
          onPressed: () {
            if (widget.contact == null) {
              context.read<ContactsCubit>().addContact(
                    _phoneController.text,
                    _nameController.text.isEmpty ? null : _nameController.text,
                  );
            } else {
              context.read<ContactsCubit>().updateContact(
                    widget.contact!.id,
                    _phoneController.text,
                    _nameController.text.isEmpty ? null : _nameController.text,
                  );
            }
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
