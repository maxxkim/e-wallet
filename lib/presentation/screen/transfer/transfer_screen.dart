import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/state/transfer/transfer_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/transfer/transfer_cubit.dart';
import 'package:zippy/presentation/screen/payment/widgets/balance_display.dart';
import 'package:zippy/presentation/screen/payment/widgets/transaction_form_display.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';
import 'package:zippy/presentation/widget/custom_contact_button_row.dart';

class TransferScreen extends StatelessWidget with FadeInAnimationMixin {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferCubit(
        RepositoryProvider.of<TransferRepository>(context),
      )..loadData(),
      child: BlocBuilder<TransferCubit, TransferState>(
        builder: (context, state) {
          return Scaffold(
              appBar: _buildAppBar(context),
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: RefreshIndicator(
                  onRefresh: () => _handleRefresh(context),
                  child: _buildBody(context, state),
                ),
              ));
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      toolbarHeight: 40,
      leading: fadeIn(
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      title: fadeIn(
        Text(
          'Transfer',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, TransferState state) {
    if (state is TransferStateLoading) {
      return _buildLoadingContent();
    } else if (state is TransferStateLoaded) {
      return _buildLoadedContent(context);
    } else if (state is TransferStateError) {
      return _buildErrorContent(context, state.errorMessage);
    } else if (state is TransferStateSent) {
      context.go('/');
    }
    return _buildErrorContent(context, "Unknown state");
  }

  Widget _buildLoadingContent() {
    return fadeIn(
      const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading Transfer options...'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: staggeredFadeIn([
          fadeInFromTop(const BalanceDisplay()),
          const SizedBox(height: 16),
          Center(
            child: fadeIn(
              ContactButtonRow(
                buttons: [
                  ContactButton(
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.add,
                    subtitle: 'New\nContact',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.primary,
                    icon: Icons.arrow_right_alt,
                    subtitle: 'New\nTransaction',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    icon: Icons.person,
                    subtitle: 'Enrique\nIglesias',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    icon: Icons.person,
                    subtitle: 'Lionel\nMessi',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    icon: Icons.person,
                    subtitle: 'Juan\nPeron',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    icon: Icons.person,
                    subtitle: 'John\nDoe',
                  ),
                  ContactButton(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    icon: Icons.person,
                    subtitle: 'Ximena\nMerino',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          fadeIn(
            const TransactionFormDisplay(),
            delay: 200,
          ),
          const SizedBox(height: 4),
        ]),
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String message) {
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
              child: const Text('Retry'),
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
