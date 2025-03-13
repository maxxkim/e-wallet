import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/state/contacts/contacts_state.dart';
import 'package:zippy/presentation/bloc/contacts/contacts_cubit.dart';
import 'package:zippy/presentation/screen/contacts/widgets/contact_dialog.dart';
import 'package:zippy/presentation/screen/contacts/widgets/contact_tile.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) =>
          ContactsCubit(RepositoryProvider.of(context))..loadContacts(),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            toolbarHeight: 24,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<ContactsCubit, ContactsState>(
              listener: (context, state) {
                if (state is ContactsStateError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.errorMessage)),
                  );
                } else if (state is ContactsStateLoaded) {
                  // Display any message stored in cubit
                  final message = context.read<ContactsCubit>().lastMessage;
                  if (message != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                    // Reset the message after displaying
                    context.read<ContactsCubit>().lastMessage = null;
                  }
                }
              },
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
                          onPressed: () {
                            context.read<ContactsCubit>().loadContacts();
                          },
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  );
                }
                if (state is ContactsStateLoaded) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        l10n.contactsTitle,
                        style: Theme.of(context).textTheme.displayLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.only(left: 64.0, right: 64.0),
                        child: RectangularButton(
                          label: l10n.contactsAddNew,
                          onPressed: () => _showContactDialog(context),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          l10n.contactsMyContacts,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: state.contacts.length,
                          itemBuilder: (context, index) {
                            final contact = state.contacts[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: ContactTile(
                                contact: contact,
                                onEdit: () => _showContactDialog(context,
                                    contact: contact),
                                onDelete: () =>
                                    _showDeleteDialog(context, contact),
                                onShare: () => _shareContact(context, contact),
                                onCopy: () => _copyContact(context, contact),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomNavigationBar: const CustomBottomNavBar(),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context, {ContactModel? contact}) {
    showDialog(
      context: context,
      builder: (context) => ContactDialog(contact: contact),
    ).then((_) {
      context.read<ContactsCubit>().loadContacts();
    });
  }

  void _showDeleteDialog(BuildContext context, ContactModel contact) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.contactsDeleteConfirmTitle),
        content: Text(l10n.contactsDeleteConfirmMessage(contact.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await context.read<ContactsCubit>().deleteContact(contact.name);
                // Snackbar will be displayed via BlocListener
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error deleting contact: $e"),
                    ),
                  );
                }
              }
            },
            child: Text(l10n.contactsDelete),
          ),
        ],
      ),
    ).then((_) {
      context.read<ContactsCubit>().loadContacts();
    });
  }

  Future<void> _shareContact(BuildContext context, ContactModel contact) async {
    try {
      final shareText =
          '''Contact Details─────────────────Name: ${contact.name}${contact.nickname != null ? 'Nickname: ${contact.nickname}\n' : ''}Phone: ${contact.name}Country: ${contact.country}''';
      await Share.share(shareText, subject: 'Contact Details');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact details shared successfully! ✨'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _copyContact(BuildContext context, ContactModel contact) async {
    try {
      final textToCopy = contact.name;
      await Clipboard.setData(ClipboardData(text: textToCopy));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact details copied to clipboard! 📋'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
