import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/contact_picker_state.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/search/global_search_cubit.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/bloc/transfer/contact_picker_cubit.dart';
import 'package:zippy/presentation/screen/payment/widgets/transfer_display.dart';
import 'package:zippy/presentation/screen/payment/widgets/transaction_form_display.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';
import 'package:zippy/presentation/widget/custom_contact_button_row.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen>
    with FadeInAnimationMixin {
  List<ContactModel> recentContacts = [];
  bool isLoading = true;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecentContacts();
  }

  Future<void> _loadRecentContacts() async {
    try {
      final contacts = await RepositoryProvider.of<TransferRepository>(context)
          .getRecentContacts();
      setState(() {
        recentContacts = contacts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e UwU')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransferCubit(
            RepositoryProvider.of<TransferRepository>(context),
          )..loadData(),
        ),
        BlocProvider(
          create: (context) => ContactPickerCubit(),
        ),
        BlocProvider(
          create: (context) => GlobalSearchCubit(
            RepositoryProvider.of<GlobalSearchRepository>(context),
          ),
        ),
      ],
      child: BlocListener<ContactPickerCubit, ContactPickerState>(
        listener: (context, state) {
          if (state is ContactSelected) {
            phoneController.text = state.phoneNumber;
          }
        },
        child: BlocListener<TransferCubit, TransferState>(
          listener: (context, state) {
            if (state is TransferStateSent) {
              // Navigate to the PaymentInfoScreen with the transaction data
              context.go(
                '/dashboard/transaction-details',
                extra: state.transaction,
              );
            } else if (state is TransferStateError) {
              if (state.isRecipientNotFound) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.transferRecipientNotFound),
                  ),
                );
              }
            }
          },
          child: BlocBuilder<TransferCubit, TransferState>(
            builder: (context, state) {
              return Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RefreshIndicator(
                    onRefresh: () => _handleRefresh(context),
                    child: _buildBody(context, state, l10n),
                  ),
                ),
                bottomNavigationBar: const CustomBottomNavBar(),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransferState state,
    AppLocalizations l10n,
  ) {
    if (state is TransferStateLoading) {
      return _buildLoadingContent(l10n);
    } else if (state is TransferStateLoaded) {
      return _buildLoadedContent(context, l10n);
    } else if (state is TransferStateError) {
      return _buildErrorContent(context, state.errorMessage, l10n);
    } else {
      return _buildLoadedContent(context, l10n);
    }
  }

  Widget _buildLoadedContent(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: staggeredFadeIn([
          const SizedBox(height: 32),
          fadeInFromTop(const TransferDisplay()),
          const SizedBox(height: 16),
          Center(
            child: fadeIn(
              isLoading
                  ? const CircularProgressIndicator()
                  : ContactButtonRow(
                      buttons: [
                        ContactButton(
                          icon: SvgPicture.asset(
                            'assets/images/icon_z.svg',
                            height: 28.0,
                            width: 28.0,
                          ),
                          subtitle: l10n.transferZentroContacts,
                          onTap: () =>
                              context.go('/dashboard/transfer/contacts'),
                        ),
                        ...recentContacts
                            .map((contact) => ContactButton(
                                  icon: const Icon(Icons.person),
                                  subtitle: contact.nickname ?? contact.name,
                                  onTap: () {
                                    phoneController.text = contact.name;
                                  },
                                ))
                            .toList(),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          fadeIn(
            TransactionFormDisplay(
              emailController: phoneController,
              amountController: amountController,
            ),
            delay: 200,
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }

  Widget _buildLoadingContent(AppLocalizations l10n) {
    return fadeIn(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.transferLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    String message,
    AppLocalizations l10n,
  ) {
    return fadeIn(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _handleRefresh(context),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh(BuildContext context) async {
    await context.read<TransferCubit>().loadData();
    await _loadRecentContacts();
  }
}
