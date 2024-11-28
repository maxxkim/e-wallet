import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/domain/state/topUp/top_up_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/topUp/top_up_cubit.dart';
import 'package:zippy/presentation/screen/topUp/widgets/provider_list.dart';
import 'package:zippy/presentation/screen/topUp/widgets/top_up_balance_display.dart';

class TopUpScreen extends StatelessWidget with FadeInAnimationMixin {
  const TopUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TopUpCubit(
        RepositoryProvider.of<TopUpRepository>(context),
      )..loadData(),
      child: BlocBuilder<TopUpCubit, TopUpState>(
        builder: (context, state) {
          return Scaffold(
            //  appBar: _buildAppBar(context),
            body: RefreshIndicator(
              onRefresh: () => _handleRefresh(context),
              child: _buildBody(context, state),
            ),
          );
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
          'Top Up',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildBody(BuildContext context, TopUpState state) {
    if (state is TopUpStateLoading) {
      return _buildLoadingContent();
    } else if (state is TopUpStateLoaded) {
      return _buildLoadedContent(context, state);
    } else if (state is TopUpStateError) {
      return _buildErrorContent(context, state.errorMessage);
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
            Text('Loading providers...'),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedContent(BuildContext context, TopUpStateLoaded state) {
    if (state.providers.isEmpty) {
      return fadeIn(
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No providers available',
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
                isWithdrawal: false,
              ),
              delay: 200,
            ),
          ]),
        ),
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
    await context.read<TopUpCubit>().loadData();
  }
}
