import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/model/search/global_search_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/repository/search/global_search_repository.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlobalSearchWidget extends StatefulWidget {
  final Function(dynamic)? onResultSelected;
  final bool showResults;
  final String? hintText;
  final bool fullWidth;
  final bool autofocus;
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _searchDebounce;

  bool _isLoading = false;
  String _errorMessage = '';
  GlobalSearchResponse? _searchResults;
  bool _showResults = false;
  bool _keepOverlayOpen =
      false; // Flag to keep overlay open when tapped outside

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _searchController.addListener(_onSearchChanged);

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _showResults = true);
      final query = _searchController.text.trim();
      if (query.isNotEmpty) {
        _performSearch(query);
      }
      _showOverlay();
      _keepOverlayOpen = true; // Set flag when focus gained
    } else if (!_keepOverlayOpen) {
      // Only hide if we're not keeping it open
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus && !_keepOverlayOpen) {
          setState(() => _showResults = false);
          _removeOverlay();
        }
      });
    }
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();

    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _errorMessage = '';
        _isLoading = false;
      });
      _updateOverlay();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _performSearch(query);
      }
    });
  }

  // Helper method to safely format dates
  String _safeFormatDate(dynamic dateValue) {
    if (dateValue == null) return '';

    try {
      final dateStr = dateValue.toString();
      final date = DateTime.tryParse(dateStr);
      if (date != null) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      print("Error formatting date: $e");
    }

    return '';
  }

  Future<void> _performSearch(String query) async {
    print("UwU Performing search for: $query");
    if (query.isEmpty) {
      setState(() {
        _searchResults = null;
        _isLoading = false;
        _errorMessage = '';
      });
      _updateOverlay();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _updateOverlay();

    try {
      final repository = RepositoryProvider.of<GlobalSearchRepository>(context);
      final results = await repository.searchGlobal(query);

      // Safety check for results
      if (results != null) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
        print(
            "Kawaii~ Search completed with ${results.transactions?.length} transactions, ${results.contacts?.length} contacts");
      } else {
        setState(() {
          _searchResults = null;
          _isLoading = false;
          _errorMessage = 'No results found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print("Error in search: $e");
    }

    _updateOverlay();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = null;
      _errorMessage = '';
    });
    _updateOverlay();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _keepOverlayOpen = false; // Reset flag when overlay is removed
  }

  void _updateOverlay() {
    if (_overlayEntry == null) {
      if (_focusNode.hasFocus || _keepOverlayOpen) _showOverlay();
      return;
    }

    _overlayEntry!.markNeedsBuild();
  }

  void _handleResultSelected(dynamic result) {
    if (widget.clearOnSelect) {
      _clearSearch();
    }

    _focusNode.unfocus();
    setState(() {
      _keepOverlayOpen = false; // Reset flag when result is selected
    });

    if (widget.onResultSelected != null) {
      widget.onResultSelected!(result);
      return;
    }

    if (result is Map<String, dynamic> && result['type'] == 'transaction') {
      final transactionData = result['data'];
      final transaction = Transaction(
        id: transactionData['transactionId'] ?? '',
        title: transactionData['name'] ?? '',
        date: DateTime.parse(
            transactionData['createdAt'] ?? DateTime.now().toString()),
        status: (transactionData['status'] ?? '').toLowerCase(),
        currency: transactionData['currency'] ?? '',
        type: (transactionData['type'] ?? '').toLowerCase(),
        amount: double.parse(transactionData['amount']?.toString() ?? '0'),
      );
      context.go('/dashboard/transaction-details', extra: transaction);
    } else if (result is Transaction) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          _focusNode
              .requestFocus(); // Give focus to the search field when container is tapped
        },
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          margin: EdgeInsets.symmetric(horizontal: widget.fullWidth ? 0 : 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: _focusNode.hasFocus || _keepOverlayOpen
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiaryContainer,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? l10n.historySearchHint,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16.0),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) => GestureDetector(
        // This gesture detector will handle taps outside the overlay
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // When tapped outside, don't dismiss but keep focus on search field
          _keepOverlayOpen = true;
          _focusNode.requestFocus();
        },
        child: Stack(
          children: [
            // This Positioned widget takes up the entire screen to catch taps
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _keepOverlayOpen = true;
                  _focusNode.requestFocus();
                },
              ),
            ),
            // The actual dropdown container
            Positioned(
              width: size.width,
              top: offset.dy + size.height,
              left: offset.dx,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 4),
                child: GestureDetector(
                  // This stops tap events from propagating up and triggering the onTap above
                  onTap: () {},
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: _buildSearchResults(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          "Error: $_errorMessage",
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    if (_searchResults == null || !_showResults) {
      return const SizedBox.shrink();
    }

    final results = _searchResults!;

    // Safely check if lists are not null before checking if they're not empty
    final hasContacts = results.contacts?.isNotEmpty ?? false;
    final hasTransactions = results.transactions?.isNotEmpty ?? false;
    final hasOffers = results.offers?.isNotEmpty ?? false;
    final hasCategories = results.categories?.isNotEmpty ?? false;
    final hasMerchants = results.merchants?.isNotEmpty ?? false;

    final hasResults = hasContacts ||
        hasTransactions ||
        hasOffers ||
        hasCategories ||
        hasMerchants;

    if (!hasResults) {
      return _buildNoResults(context);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTransactions)
            _buildResultSection(
              context: context,
              title: l10n.dashboardTransactionHistory,
              count: results.transactions?.length ?? 0,
              icon: Icons.receipt_long,
              onViewAll: () {
                context
                    .read<DashboardCubit>()
                    .searchTransactions(_searchController.text);
                context.go('/dashboard/history');
                _focusNode.unfocus();
                setState(() {
                  _keepOverlayOpen = false;
                });
              },
              itemBuilder: (context, index) {
                if (index < 0 || index >= (results.transactions?.length ?? 0)) {
                  return const SizedBox(height: 0);
                }
                return _buildApiTransactionItem(
                    context, results.transactions![index]);
              },
              itemCount: results.transactions?.length ?? 0,
            ),
          if (hasContacts)
            _buildResultSection(
              context: context,
              title: l10n.contactsTitle,
              count: results.contacts?.length ?? 0,
              icon: Icons.contacts,
              onViewAll: () {
                context.go('/dashboard/transfer/contacts');
                _focusNode.unfocus();
                setState(() {
                  _keepOverlayOpen = false;
                });
              },
              itemBuilder: (context, index) {
                if (index < 0 || index >= (results.contacts?.length ?? 0)) {
                  return const SizedBox(height: 0);
                }
                return _buildContactItem(context, results.contacts![index]);
              },
              itemCount: results.contacts?.length ?? 0,
            ),
          if (hasOffers)
            _buildResultSection(
              context: context,
              title: l10n.offerFilterCategory,
              count: results.offers?.length ?? 0,
              icon: Icons.local_offer,
              onViewAll: () {
                context.go('/dashboard/offers');
                _focusNode.unfocus();
                setState(() {
                  _keepOverlayOpen = false;
                });
              },
              itemBuilder: (context, index) {
                if (index < 0 || index >= (results.offers?.length ?? 0)) {
                  return const SizedBox(height: 0);
                }
                return _buildOfferItem(context, results.offers![index]);
              },
              itemCount: results.offers?.length ?? 0,
            ),
          if (hasCategories || hasMerchants)
            _buildResultSection(
              context: context,
              title:
                  "${l10n.offerFilterCategory} & ${l10n.offerFilterMerchant}",
              count: (results.categories?.length ?? 0) +
                  (results.merchants?.length ?? 0),
              icon: Icons.category,
              onViewAll: () {
                context.go('/dashboard/offers');
                _focusNode.unfocus();
                setState(() {
                  _keepOverlayOpen = false;
                });
              },
              itemBuilder: (context, index) {
                final categoriesLength = results.categories?.length ?? 0;

                if (index < categoriesLength && results.categories != null) {
                  if (index < 0 || index >= results.categories!.length) {
                    return const SizedBox(height: 0);
                  }
                  return _buildCategoryItem(
                      context, results.categories![index]);
                } else if (results.merchants != null) {
                  final merchantIndex = index - categoriesLength;
                  if (merchantIndex < 0 ||
                      merchantIndex >= results.merchants!.length) {
                    return const SizedBox(height: 0);
                  }
                  return _buildMerchantItem(
                      context, results.merchants![merchantIndex]);
                } else {
                  return const SizedBox(height: 0);
                }
              },
              itemCount: (results.categories?.length ?? 0) +
                  (results.merchants?.length ?? 0),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
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
    required BuildContext context,
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
          itemBuilder: (context, index) => itemBuilder(context, index),
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

  Widget _buildApiTransactionItem(
      BuildContext context, Map<String, dynamic> transaction) {
    // Safely handle potentially null values
    String type = transaction['type']?.toString().toLowerCase() ?? '';
    bool isInbound = type == 'payin';

    // Safely get transactionId and substring
    String transactionId = '';
    if (transaction['transactionId'] != null) {
      String id = transaction['transactionId'].toString();
      transactionId = id.length > 8 ? id.substring(0, 8) : id;
    }

    String displayAmount = '0';
    try {
      final amount = transaction['amount'];
      if (amount != null) {
        if (amount is num) {
          displayAmount = amount.toString();
        } else {
          displayAmount = amount.toString();
        }
      }
    } catch (e) {
      print("Error parsing amount: $e");
      displayAmount = '0';
    }

    String currencySymbol = transaction['currency']?.toString() ?? '\$';

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
        transaction['name']?.toString() ?? transactionId ?? 'Transaction',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        _safeFormatDate(transaction['createdAt']),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Text(
        '${isInbound ? '+' : '-'} $currencySymbol $displayAmount',
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

  Widget _buildContactItem(BuildContext context, ContactModel contact) {
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

  Widget _buildOfferItem(BuildContext context, Offer offer) {
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

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
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

  Widget _buildMerchantItem(
      BuildContext context, MerchantSearchResult merchant) {
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
