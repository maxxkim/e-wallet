import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/pagination/pagination_mixin.dart';
import 'package:zippy/presentation/screen/dashboard/dashboard_screen.dart';
import 'package:zippy/presentation/screen/history/history_screen.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionList extends StatefulWidget {
  final List<Transaction> transactions;
  final TransactionListTranslations translations;
  const TransactionList({
    super.key,
    required this.transactions,
    required this.translations,
  });

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList>
    with PaginationMixin {
  @override
  int get pageSize => 10;

  String get _currentSearchQuery {
    final state = context.read<DashboardCubit>().state;
    if (state is DashboardStateLoaded) {
      return state.searchQuery;
    }
    return '';
  }

  bool get _hasActiveFilters {
    final state = context.read<DashboardCubit>().state;
    if (state is DashboardStateLoaded) {
      return state.filterType != FilterType.period ||
          state.searchQuery.isNotEmpty;
    }
    return false;
  }

  @override
  void loadMoreItems() {
    if (!isLoadingMore && currentPage * pageSize < widget.transactions.length) {
      setState(() {
        isLoadingMore = true;
        currentPage++;
      });

      // Simulate network delay (remove in production)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            isLoadingMore = false;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant TransactionList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions) {
      // Reset pagination when transactions change
      resetPagination();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardCubit, DashboardState>(
      listener: (context, state) {
        if (state is DashboardStateLoaded &&
            state.searchQuery != _currentSearchQuery) {
          resetPagination();
        }
      },
      builder: (context, state) {
        if (state is DashboardStateLoaded) {
          return Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMonthSelector(context, state),
                  Expanded(
                    child: widget.transactions.isEmpty
                        ? _buildEmptyState(context)
                        : _buildTransactionsList(context),
                  ),
                ],
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildMonthSelector(BuildContext context, DashboardStateLoaded state) {
    final l10n = AppLocalizations.of(context)!;
    final List<MonthData> months = [
      MonthData(1, l10n.monthJanuary),
      MonthData(2, l10n.monthFebruary),
      MonthData(3, l10n.monthMarch),
      MonthData(4, l10n.monthApril),
      MonthData(5, l10n.monthMay),
      MonthData(6, l10n.monthJune),
      MonthData(7, l10n.monthJuly),
      MonthData(8, l10n.monthAugust),
      MonthData(9, l10n.monthSeptember),
      MonthData(10, l10n.monthOctober),
      MonthData(11, l10n.monthNovember),
      MonthData(12, l10n.monthDecember),
    ];

    final currentMonthNumber = state.selectedMonthNumber;
    return Container(
      height: 48.0,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 1.0,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(32),
          bottom: Radius.circular(32),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final isSelected = month.number == currentMonthNumber;
          return GestureDetector(
            onTap: () {
              resetPagination();
              context.read<DashboardCubit>().selectMonth(month.localizedName);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  month.localizedName,
                  style: isSelected
                      ? Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          )
                      : Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _hasActiveFilters
                ? widget.translations.noTransactions
                : widget.translations.noTransactions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayItemCount = getDisplayItemCount(widget.transactions.length);

    return RefreshIndicator(
      onRefresh: () {
        resetPagination();
        return context.read<DashboardCubit>().loadData();
      },
      child: Stack(
        children: [
          ListView.builder(
            controller: scrollController,
            itemCount: displayItemCount + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == displayItemCount && isLoadingMore) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Column(
                      children: [
                        const CircularProgressIndicator(strokeWidth: 2),
                        const SizedBox(height: 8),
                        Text(
                          l10n.historyLoadingMore,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Regular transaction item
              if (index < displayItemCount) {
                return Column(
                  children: [
                    TransactionTile(
                      transaction: widget.transactions[index],
                      onIconTap: () => context.go(
                        '/dashboard/transaction-details',
                        extra: widget.transactions[index],
                      ),
                    ).animate().fadeIn(
                          duration: const Duration(milliseconds: 300),
                          delay: Duration(milliseconds: index % pageSize * 50),
                        ),
                    Container(
                      height: 1,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
          // Scroll to top button (only show if we've scrolled down)
          if (currentPage > 1)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.small(
                heroTag: 'scrollToTopBtn',
                tooltip: l10n.historyScrollToTop,
                onPressed: scrollToTop,
                child: const Icon(Icons.arrow_upward),
              ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                  ),
            ),
        ],
      ),
    );
  }
}
