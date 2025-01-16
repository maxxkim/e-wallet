import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/contact_picker_state.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/bloc/transfer/contact_picker_cubit.dart';
import 'package:zippy/presentation/screen/payment/widgets/transfer_display.dart';
import 'package:zippy/presentation/screen/payment/widgets/transaction_form_display.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';
import 'package:zippy/presentation/widget/custom_contact_button_row.dart';

class TransferScreen extends StatelessWidget with FadeInAnimationMixin {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final phoneController = TextEditingController();
    final amountController = TextEditingController();

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
      ],
      child: BlocListener<ContactPickerCubit, ContactPickerState>(
        listener: (context, state) {
          if (state is ContactSelected) {
            phoneController.text = state.phoneNumber;
          }
        },
        child: BlocBuilder<TransferCubit, TransferState>(
          builder: (context, state) {
            return Scaffold(
              appBar: _buildAppBar(context, l10n),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RefreshIndicator(
                  onRefresh: () => _handleRefresh(context),
                  child: _buildBody(
                      context, state, l10n, phoneController, amountController),
                ),
              ),
              bottomNavigationBar: const CustomBottomNavBar(),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      toolbarHeight: 24,
    );
  }

  Widget _buildBody(
    BuildContext context,
    TransferState state,
    AppLocalizations l10n,
    TextEditingController phoneController,
    TextEditingController amountController,
  ) {
    if (state is TransferStateLoading) {
      return _buildLoadingContent(l10n);
    } else if (state is TransferStateLoaded) {
      return _buildLoadedContent(
          context, l10n, phoneController, amountController);
    } else if (state is TransferStateError) {
      if (state.isRecipientNotFound) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.transferRecipientNotFound),
            ),
          );
        });
      }
      return _buildErrorContent(context, state.errorMessage, l10n);
    } else if (state is TransferStateSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/dashboard');
      });
      return _buildLoadedContent(
          context, l10n, phoneController, amountController);
    }
    return _buildErrorContent(context, l10n.transferUnknownError, l10n);
  }

  Widget _buildLoadedContent(
    BuildContext context,
    AppLocalizations l10n,
    TextEditingController phoneController,
    TextEditingController amountController,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: staggeredFadeIn([
          fadeInFromTop(const TransferDisplay()),
          const SizedBox(height: 16),
          /*Center(
            child: fadeIn(
              ContactButtonRow(
                buttons: [
                  ContactButton(
                    icon: Icons.add,
                    subtitle: l10n.transferNewContact,
                  ),
                  ContactButton(
                    icon: Icons.person,
                    subtitle: l10n.transferNewTransaction,
                    /*onTap: () {
                      context.read<ContactPickerCubit>().pickContact();
                    },*/
                  ),
                ],
              ),
            ),
          ),*/
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
            const SizedBox(height: 16),
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
  }
}
