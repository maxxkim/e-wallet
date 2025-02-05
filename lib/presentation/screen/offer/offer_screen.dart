import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/domain/state/offer/offer_state.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';
import 'package:zippy/presentation/widget/custom_bottom_nav_bar.dart';
import 'package:zippy/presentation/screen/offer/widgets/offer_tile.dart';
import 'package:zippy/presentation/screen/offer/widgets/category_filter_dialog.dart';

enum OfferFilterType { category, merchant, discount }

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
              SizedBox(
                height: 120,
                child: FutureBuilder<List<Offer>>(
                  future: RepositoryProvider.of<OfferRepository>(context)
                      .getTopOffers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const SizedBox.shrink();
                    }
                    final topOffers = snapshot.data ?? [];
                    if (topOffers.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: topOffers.length,
                      itemBuilder: (context, index) {
                        final offer = topOffers[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                offer.image,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .tertiaryContainer,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    child: Icon(
                                      Icons.error_outline,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterButtons(context, l10n),
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
            OfferTile(
              offer: offer,
              onTap: () {
                // Handle offer tap
              },
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

  Widget _buildFilterButtons(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<OfferCubit, OfferState>(
      builder: (context, state) {
        final isFiltered =
            state is OfferStateLoaded && state.selectedCategories.isNotEmpty;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildFilterButton(
              context,
              l10n.offerFilterCategory,
              OfferFilterType.category,
              isFiltered,
              state is OfferStateLoaded ? state.selectedCategories : [],
            ),
            _buildFilterButton(
              context,
              l10n.offerFilterMerchant,
              OfferFilterType.merchant,
              false,
              [],
            ),
            _buildFilterButton(
              context,
              l10n.offerFilterDiscount,
              OfferFilterType.discount,
              false,
              [],
            ),
          ],
        ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
            );
      },
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String label,
    OfferFilterType type,
    bool isSelected,
    List<dynamic> selectedItems,
  ) {
    const double buttonHeight = 40.0;
    const double buttonWidth = 114.0;

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: isSelected
          ? Container(
              decoration: BoxDecoration(
                gradient: Theme.of(context)
                    .extension<ThemeGradients>()
                    ?.darkBlueGradient,
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: FilledButton(
                onPressed: () => _handleFilterTap(context, type, selectedItems),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 20.0),
                  ),
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                ),
                child: Text(
                  selectedItems.length > 1
                      ? '${selectedItems.length} selected'
                      : label,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
            )
          : OutlinedButton(
              style: ButtonStyle(
                side: WidgetStateProperty.all(
                  BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              onPressed: () => _handleFilterTap(context, type, selectedItems),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
    );
  }

  void _handleFilterTap(
      BuildContext context, OfferFilterType type, List<dynamic> selectedItems) {
    switch (type) {
      case OfferFilterType.category:
        final cubit = context.read<OfferCubit>();
        showDialog(
          context: context,
          builder: (dialogContext) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: CategoryFilterDialog(
                selectedCategories: selectedItems.cast<CategoryModel>(),
                onCategoriesSelected: (categories) {
                  cubit.selectCategories(categories);
                },
              ),
            );
          },
        );
        break;
      case OfferFilterType.merchant:
        // TODO: Handle merchant filter
        break;
      case OfferFilterType.discount:
        // TODO: Handle discount filter
        break;
    }
  }
}
