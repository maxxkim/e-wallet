// lib/presentation/screen/offer/widgets/category_filter_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class CategoryFilterDialog extends StatefulWidget {
  final Function(CategoryModel?) onCategorySelected;
  final CategoryModel? selectedCategory;

  const CategoryFilterDialog({
    Key? key,
    required this.onCategorySelected,
    this.selectedCategory,
  }) : super(key: key);

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final repository = RepositoryProvider.of<OfferRepository>(context);
      final responses = await Future.wait([
        repository.getCategories(),
        repository.getFavoriteCategories(),
      ]);

      if (mounted) {
        setState(() {
          _categories = responses[0];
          _favorites = responses[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load categories >~<';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite(CategoryModel category) async {
    try {
      final repository = RepositoryProvider.of<OfferRepository>(context);
      final isFavorite = _favorites.any((fav) => fav.id == category.id);

      final updatedFavorites = isFavorite
          ? await repository.deleteFavoriteCategory(category.id)
          : await repository.addFavoriteCategory(category.id);

      if (mounted) {
        setState(() {
          _favorites = updatedFavorites;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating favorites: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Favorite',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total offers',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            if (_favorites.isNotEmpty) ...[
              ..._favorites
                  .map((category) => _buildCategoryItem(context, category)),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All Categories',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            ..._categories
                .where((cat) => !_favorites.any((fav) => fav.id == cat.id))
                .map((category) => _buildCategoryItem(context, category)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    final isFavorite = _favorites.any((fav) => fav.id == category.id);
    final isSelected = widget.selectedCategory?.id == category.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => widget.onCategorySelected(isSelected ? null : category),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${category.totalOffers} offers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: isFavorite
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey,
                ),
                onPressed: () => _toggleFavorite(category),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
