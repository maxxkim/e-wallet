import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';

class DiscountFilterDialog extends StatefulWidget {
  final double? minDiscount;
  final double? maxDiscount;
  final String sortDirection;
  final List<String> selectedTypes;

  const DiscountFilterDialog({
    Key? key,
    this.minDiscount,
    this.maxDiscount,
    required this.sortDirection,
    required this.selectedTypes,
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
          SnackBar(content: Text('Failed to load offer types: $e')),
        );
      }
    }
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
                },
              ),
              const SizedBox(width: 8),
              _buildSortButton(
                icon: Icons.arrow_downward_rounded,
                isSelected: sortDirection == 'desc',
                onTap: () {
                  setState(() => sortDirection = 'desc');
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
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
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
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
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
              final min = double.tryParse(_minController.text);
              final max = double.tryParse(_maxController.text);
              final selectedList = selectedTypes.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key)
                  .toList();

              context.read<OfferCubit>().applyFilters(
                    minDiscount: min,
                    maxDiscount: max,
                    sortDirection: sortDirection,
                    offerTypes: selectedList,
                  );

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
