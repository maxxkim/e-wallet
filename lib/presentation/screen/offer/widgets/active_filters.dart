import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/presentation/bloc/offer/offer_cubit.dart';
import 'package:zippy/presentation/screen/offer/widgets/merchant_filter_dialog.dart';

class ActiveFilters extends StatelessWidget {
  final List<CategoryModel> selectedCategories;
  final List<MerchantData> selectedMerchants;
  final double? minDiscount;
  final double? maxDiscount;

  const ActiveFilters({
    super.key,
    required this.selectedCategories,
    required this.selectedMerchants,
    this.minDiscount,
    this.maxDiscount,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCategories.isEmpty &&
        selectedMerchants.isEmpty &&
        minDiscount == null &&
        maxDiscount == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        ...selectedCategories.map((category) => _buildFilterChip(
              context,
              label: category.name,
              onRemove: () =>
                  context.read<OfferCubit>().removeCategory(category),
            )),
        ...selectedMerchants.map((merchant) => _buildFilterChip(
              context,
              label: merchant.name,
              onRemove: () =>
                  context.read<OfferCubit>().removeMerchant(merchant),
            )),
        if (minDiscount != null || maxDiscount != null)
          _buildFilterChip(
            context,
            label: 'Discount: ${minDiscount ?? 0}% - ${maxDiscount ?? '∞'}%',
            onRemove: () => context.read<OfferCubit>().clearDiscountFilter(),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required VoidCallback onRemove,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  ),
            ),
            const SizedBox(width: 2),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 14,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
