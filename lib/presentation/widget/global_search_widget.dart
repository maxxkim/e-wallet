import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/search/global_search_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/state/search/global_search_state.dart';
import 'package:zippy/presentation/bloc/search/global_search_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class GlobalSearchWidget extends StatefulWidget {
  // Optional callback for when a result is selected
  final Function(dynamic)? onResultSelected;
  // Whether to show results overlay
  final bool showResults;
  // Optional custom hint text
  final String? hintText;
  // Whether the widget should take full width
  final bool fullWidth;
  // Whether to autofocus the input
  final bool autofocus;
  // Whether to clear search after selection
  final bool clearOnSelect;

  const GlobalSearchWidget({
    Key? key,
    this.onResultSelected,
    this.showResults = true,
    this.hintText,
    this.fullWidth = true,
    this.autofocus = false,
    this.clearOnSelect = false,
  }) : super(key: key);

  @override
  State<GlobalSearchWidget> createState() => _GlobalSearchWidgetState();
}

class _GlobalSearchWidgetState extends State<GlobalSearchWidget> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        width: widget.fullWidth ? double.infinity : null,
        margin: EdgeInsets.symmetric(horizontal: widget.fullWidth ? 0 : 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: _focusNode.hasFocus
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.tertiaryContainer,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: context.read<GlobalSearchCubit>().searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? l10n.historySearchHint,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
                    builder: (context, state) {
                      if (state is GlobalSearchInitial) {
                        return const SizedBox.shrink();
                      }
                      return IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          context.read<GlobalSearchCubit>().clearSearch();
                        },
                      );
                    },
                  ),
                ),
                onChanged: (value) {
                  // This ensures search happens on every keystroke (after debounce)
                  // rather than only on submit
                  print("Search text changed: $value");
                  if (value.isNotEmpty) {
                    // Directly trigger search without relying on listener
                    context.read<GlobalSearchCubit>().search(value);
                  }
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    print("Search submitted: $value");
                    context.read<GlobalSearchCubit>().search(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    print("Focus changed: hasFocus=${_focusNode.hasFocus}");

    if (_focusNode.hasFocus) {
      // When focus is gained, show the overlay and search with current text
      _showOverlay();
      context.read<GlobalSearchCubit>().showResults();

      // If there's text already in the field, trigger a search
      final query =
          context.read<GlobalSearchCubit>().searchController.text.trim();
      if (query.isNotEmpty) {
        print("Focus gained with existing query: $query");
        context.read<GlobalSearchCubit>().search(query);
      }
    } else {
      // Add a short delay before removing overlay to allow for interactions
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _removeOverlay();
          context.read<GlobalSearchCubit>().hideResults();
        }
      });
    }
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = _createOverlayEntry();

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _rebuildOverlay() {
    if (_overlayEntry == null) return;
    _overlayEntry!.markNeedsBuild();
  }

  void _handleResultSelected(dynamic result) {
    if (widget.clearOnSelect) {
      context.read<GlobalSearchCubit>().clearSearch();
    }
    _focusNode.unfocus();
    if (widget.onResultSelected != null) {
      widget.onResultSelected!(result);
      return;
    }

    if (result is Map<String, dynamic> && result['type'] == 'transaction') {
      // Handle transaction from API response format
      final transactionData = result['data'];
      final transaction = Transaction(
        id: transactionData['transactionId'] ?? '',
        title: transactionData['name'] ?? '',
        date: DateTime.parse(
            transactionData['createdAt'] ?? DateTime.now().toString()),
        status: (transactionData['status'] ?? '').toLowerCase(),
        currency: transactionData['currency'] ?? '',
        type: (transactionData['type'] ?? '').toLowerCase(),
        amount: double.parse(transactionData['amount'] ?? '0'),
      );
      context.go('/dashboard/transaction-details', extra: transaction);
    } else if (result is Transaction) {
      // Handle standard Transaction object
      context.go('/dashboard/transaction-details', extra: result);
    } else if (result is ContactModel) {
      context.go('/dashboard/transfer', extra: result);
    } else if (result is Offer) {
      context.go('/dashboard/offers', extra: result);
    } else if (result is MerchantSearchResult) {
      final merchantData = result.toMerchantData();
      final offerCubit = context.read<OfferCubit>();
      offerCubit.selectMerchants([merchantData]);
      context.go('/dashboard/offers');
    } else if (result is CategoryModel) {
      final offerCubit = context.read<OfferCubit>();
      offerCubit.selectCategories([result]);
      context.go('/dashboard/offers');
    }
  }

  OverlayEntry _createOverlayEntry() {
    // Make sure we get the correct size
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    print("Creating overlay entry, size: $size, offset: $offset");

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        // Position directly below the search widget
        top: offset.dy + size.height,
        left: offset.dx,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: _buildSearchResults(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    print("Building search results");
    return BlocConsumer<GlobalSearchCubit, GlobalSearchState>(
      listenWhen: (previous, current) {
        // Listen for any state change
        print("State changed from $previous to $current");
        return true;
      },
      listener: (context, state) {
        print("BlocConsumer listener: $state");
        if (state is GlobalSearchLoaded) {
          print(
              "Rebuilding overlay with ${state.results.transactions.length} transactions");
          _rebuildOverlay();
        } else if (state is GlobalSearchLoading) {
          print("Search is loading...");
          _rebuildOverlay();
        } else if (state is GlobalSearchError) {
          print("Search error: ${state.errorMessage}");
          _rebuildOverlay();
        }
      },
      builder: (context, state) {
        if (state is GlobalSearchLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is GlobalSearchLoaded && state.showResults) {
          final results = state.results;

          final hasResults = results.contacts.isNotEmpty ||
              results.transactions.isNotEmpty ||
              results.offers.isNotEmpty ||
              results.categories.isNotEmpty ||
              results.merchants.isNotEmpty;
          if (!hasResults) {
            return _buildNoResults();
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (results.transactions.isNotEmpty)
                  _buildResultSection(
                    title: AppLocalizations.of(context)!
                        .dashboardTransactionHistory,
                    count: results.transactions.length,
                    icon: Icons.receipt_long,
                    onViewAll: () {
                      // Navigate to transaction history with search
                      context.read<DashboardCubit>().searchTransactions(context
                          .read<GlobalSearchCubit>()
                          .searchController
                          .text);
                      context.go('/dashboard/history');
                      _focusNode.unfocus();
                    },
                    itemBuilder: (context, index) =>
                        _buildApiTransactionItem(results.transactions[index]),
                    itemCount: results.transactions.length,
                  ),
                if (results.contacts.isNotEmpty)
                  _buildResultSection(
                    title: AppLocalizations.of(context)!.contactsTitle,
                    count: results.contacts.length,
                    icon: Icons.contacts,
                    onViewAll: () {
                      context.go('/dashboard/transfer/contacts');
                      _focusNode.unfocus();
                    },
                    itemBuilder: (context, index) =>
                        _buildContactItem(results.contacts[index]),
                    itemCount: results.contacts.length,
                  ),
                if (results.offers.isNotEmpty)
                  _buildResultSection(
                    title: AppLocalizations.of(context)!.offerFilterCategory,
                    count: results.offers.length,
                    icon: Icons.local_offer,
                    onViewAll: () {
                      context.go('/dashboard/offers');
                      _focusNode.unfocus();
                    },
                    itemBuilder: (context, index) =>
                        _buildOfferItem(results.offers[index]),
                    itemCount: results.offers.length,
                  ),
                if (results.categories.isNotEmpty ||
                    results.merchants.isNotEmpty)
                  _buildResultSection(
                    title: AppLocalizations.of(context)!.offerFilterCategory +
                        " & " +
                        AppLocalizations.of(context)!.offerFilterMerchant,
                    count: results.categories.length + results.merchants.length,
                    icon: Icons.category,
                    onViewAll: () {
                      context.go('/dashboard/offers');
                      _focusNode.unfocus();
                    },
                    itemBuilder: (context, index) {
                      if (index < results.categories.length) {
                        return _buildCategoryItem(results.categories[index]);
                      } else {
                        return _buildMerchantItem(results
                            .merchants[index - results.categories.length]);
                      }
                    },
                    itemCount:
                        results.categories.length + results.merchants.length,
                  ),
              ],
            ),
          );
        } else if (state is GlobalSearchError) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              state.errorMessage,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.historyNoTransactions,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection({
    required String title,
    required int count,
    required IconData icon,
    required VoidCallback onViewAll,
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
  }) {
    final displayCount = itemCount > 3 ? 3 : itemCount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Row(
            children: [
              Icon(icon,
                  size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title ($count)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (count > 3)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    AppLocalizations.of(context)!.dashboardViewAll,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          itemBuilder: itemBuilder,
        ),
        if (count > 3)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Container(
                height: 4,
                width: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildApiTransactionItem(Map<String, dynamic> transaction) {
    String type = transaction['type']?.toString().toLowerCase() ?? '';
    bool isInbound = type == 'payin';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          isInbound ? Icons.arrow_downward : Icons.arrow_upward,
          color: isInbound
              ? Theme.of(context).colorScheme.scrim
              : Theme.of(context).colorScheme.error,
        ),
      ),
      title: Text(
        transaction['name'] ??
            transaction['transactionId']?.substring(0, 8) ??
            'Transaction',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        DateTime.tryParse(transaction['createdAt'] ?? '')
                ?.toString()
                .substring(0, 10) ??
            '',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${isInbound ? '+' : '-'} ${transaction['currency']} ${transaction['amount']}',
        style: TextStyle(
          color: isInbound
              ? Theme.of(context).colorScheme.scrim
              : Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => _handleResultSelected({
        'type': 'transaction',
        'data': transaction,
      }),
    );
  }

  Widget _buildContactItem(ContactModel contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        contact.nickname ?? contact.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        contact.name,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _handleResultSelected(contact),
    );
  }

  Widget _buildOfferItem(Offer offer) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.card_giftcard,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        offer.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        offer.merchantName,
        style: Theme.of(context).textTheme.bodySmall,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: offer.discount != "0.00"
          ? Text(
              '${offer.discount}%',
              style: Theme.of(context).textTheme.inText,
            )
          : (offer.bonus != "0.00"
              ? Text(
                  '${offer.bonus}% bonus',
                  style: Theme.of(context).textTheme.inText,
                )
              : null),
      onTap: () => _handleResultSelected(offer),
    );
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.category,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        category.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        '${category.totalOffers} ${AppLocalizations.of(context)!.offersTitle}',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _handleResultSelected(category),
    );
  }

  Widget _buildMerchantItem(MerchantSearchResult merchant) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: Icon(
          Icons.store,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        merchant.name,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        AppLocalizations.of(context)!.offerFilterMerchant,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      onTap: () => _handleResultSelected(merchant),
    );
  }
}
