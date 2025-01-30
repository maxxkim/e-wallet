import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';

class OfferScreen extends StatelessWidget with FadeInAnimationMixin {
  const OfferScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<OfferCubit>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              fadeInFromTop(
                CustomTextField(
                  controller: cubit.searchController,
                  hintText: l10n.offersSearchHint,
                  icon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<OfferCubit, OfferState>(
                  builder: (context, state) {
                    if (state is OfferStateLoading) {
                      return _buildLoadingState();
                    } else if (state is OfferStateLoaded) {
                      return _buildLoadedState(context, state, l10n, cubit);
                    } else if (state is OfferStateError) {
                      return _buildErrorState(context, state, l10n);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }

  Widget _buildLoadingState() {
    return fadeIn(
      const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildLoadedState(
    BuildContext context,
    OfferStateLoaded state,
    AppLocalizations l10n,
    OfferCubit cubit,
  ) {
    if (state.offers.isEmpty) {
      return fadeIn(
        Center(
          child: Text(
            l10n.offersNoData,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => cubit.refresh(),
      child: ListView.builder(
        controller: cubit.scrollController,
        itemCount: state.offers.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.offers.length) {
            return state.isLoadingMore
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : const SizedBox.shrink();
          }

          final offer = state.offers[index];
          return fadeIn(
            Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    offer.image,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
                title: Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      offer.merchantName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (offer.discount != "0.00") ...[
                          Icon(
                            Icons.local_offer,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.discount}% ${l10n.offersDiscount}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (offer.bonus != "0.00") ...[
                          Icon(
                            Icons.stars,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${offer.bonus}% ${l10n.offersBonus}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onTap: () {
                  // Handle offer tap
                },
              ),
            ),
            delay: index * 100,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    OfferStateError state,
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
              state.errorMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<OfferCubit>().refresh(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
