import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';
import 'package:zippy/domain/state/withdrawal/withdrawal_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/withdrawal/withdrawal_cubit.dart';
import 'package:zippy/presentation/screen/topUp/widgets/provider_list.dart';
import 'package:zippy/presentation/screen/topUp/widgets/top_up_balance_display.dart';

class WithdrawalScreen extends StatelessWidget with FadeInAnimationMixin {
  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (context) => WithdrawalCubit(
        RepositoryProvider.of<WithdrawalRepository>(context),
      )..loadData(),
      child: BlocBuilder<WithdrawalCubit, WithdrawalState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context, l10n),
            body: RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: _buildBody(context, state, l10n),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AppLocalizations l10n) {
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
          l10n.withdrawalTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(
      BuildContext context, WithdrawalState state, AppLocalizations l10n) {
    if (state is WithdrawalStateLoading) {
      return _buildLoadingContent(l10n);
    } else if (state is WithdrawalStateLoaded) {
      return _buildLoadedContent(context, state, l10n);
    } else if (state is WithdrawalStateError) {
      return _buildErrorContent(context, state.errorMessage, l10n);
    }
    return _buildErrorContent(context, l10n.unknownError, l10n);
  }

  Widget _buildLoadingContent(AppLocalizations l10n) {
    return fadeIn(
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.withdrawalLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, WithdrawalStateLoaded state,
      AppLocalizations l10n) {
    if (state.providers.isEmpty) {
      return fadeIn(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.withdrawalNoMethods,
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

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: staggeredFadeIn([
            const SizedBox(height: 56),
            fadeInFromTop(const TopUpBalanceDisplay()),
            const SizedBox(height: 12),
            fadeIn(
              ProviderList(
                providers: state.providers.sublist(1),
                isWithdrawal: true,
              ),
              delay: 200,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildErrorContent(
      BuildContext context, String message, AppLocalizations l10n) {
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
    await context.read<WithdrawalCubit>().loadData();
  }
}
