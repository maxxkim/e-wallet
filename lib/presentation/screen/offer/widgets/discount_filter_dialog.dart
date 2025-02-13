import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class DiscountFilterDialog extends StatefulWidget {
  final double? minDiscount;
  final double? maxDiscount;
  final String sortDirection;
  final List<String> selectedTypes;
  final Function(double?, double?) onDiscountRangeChanged;
  final Function(String) onSortDirectionChanged;
  final Function(List<String>) onTypesChanged;

  const DiscountFilterDialog({
    Key? key,
    this.minDiscount,
    this.maxDiscount,
    required this.sortDirection,
    required this.selectedTypes,
    required this.onDiscountRangeChanged,
    required this.onSortDirectionChanged,
    required this.onTypesChanged,
  }) : super(key: key);

  @override
  State<DiscountFilterDialog> createState() => _DiscountFilterDialogState();
}

class _DiscountFilterDialogState extends State<DiscountFilterDialog> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  List<String> offerTypes = [];
  Map<String, bool> selectedTypes = {};
  late String sortDirection;

  @override
  void initState() {
    super.initState();
    _minController.text = widget.minDiscount?.toString() ?? '';
    _maxController.text = widget.maxDiscount?.toString() ?? '';
    sortDirection = widget.sortDirection;
    _loadOfferTypes();
  }

  Future<void> _loadOfferTypes() async {
    try {
      final initialData = await RepositoryProvider.of<OfferRepository>(context)
          .getInitialData();

      // Get unique offer types from the offers
      final uniqueTypes = initialData.offers
          .map((offer) => offer.type.toLowerCase())
          .toSet()
          .toList();

      setState(() {
        offerTypes = uniqueTypes;
        for (var type in offerTypes) {
          selectedTypes[type] = widget.selectedTypes.contains(type);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load offer types: $e UwU')),
        );
      }
    }
  }

  void _validateAndUpdateRange() {
    double? min = double.tryParse(_minController.text);
    double? max = double.tryParse(_maxController.text);

    if (min != null && max != null) {
      if (min > max) {
        final temp = min;
        min = max;
        max = temp;
        _minController.text = min.toString();
        _maxController.text = max.toString();
      }
      if (min < 0) min = 0;
      if (max > 100) max = 100;
    }

    widget.onDiscountRangeChanged(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSortingSection(),
            _buildRangeSection(),
            _buildTypesSection(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSortingSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sort by amount',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSortButton(
                icon: Icons.arrow_upward_rounded,
                isSelected: sortDirection == 'asc',
                onTap: () {
                  setState(() => sortDirection = 'asc');
                  widget.onSortDirectionChanged('asc');
                },
              ),
              const SizedBox(width: 8),
              _buildSortButton(
                icon: Icons.arrow_downward_rounded,
                isSelected: sortDirection == 'desc',
                onTap: () {
                  setState(() => sortDirection = 'desc');
                  widget.onSortDirectionChanged('desc');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.secondary
              : Colors.grey[300]!,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey[600],
      ),
    );
  }

  Widget _buildRangeSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by range',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '5%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (_) => _validateAndUpdateRange(),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('–'),
              ),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '100%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (_) => _validateAndUpdateRange(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypesSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by type',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: offerTypes.map((type) {
              final isSelected = selectedTypes[type] ?? false;
              return SizedBox(
                width: 150,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: isSelected,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        side: BorderSide(
                          color: isSelected
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey[300]!,
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (selected) {
                          setState(() {
                            selectedTypes[type] = selected ?? false;
                          });
                          final selectedList = selectedTypes.entries
                              .where((entry) => entry.value)
                              .map((entry) => entry.key)
                              .toList();
                          widget.onTypesChanged(selectedList);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        type,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              _validateAndUpdateRange();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'Apply',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }
}
