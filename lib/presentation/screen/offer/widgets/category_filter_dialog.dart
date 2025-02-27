import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class CategoryFilterDialog extends StatefulWidget {
  final Function(List<CategoryModel>) onCategoriesSelected;
  final List<CategoryModel> selectedCategories;

  const CategoryFilterDialog({
    Key? key,
    required this.onCategoriesSelected,
    required this.selectedCategories,
  }) : super(key: key);

  @override
  State<CategoryFilterDialog> createState() => _CategoryFilterDialogState();
}

class _CategoryFilterDialogState extends State<CategoryFilterDialog> {
  List<CategoryModel> _categories = [];
  List<CategoryModel> _favorites = [];
  List<CategoryModel> _selectedCategories = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final repository = RepositoryProvider.of<OfferRepository>(context);
      // Get initial data for categories
      final initialData = await repository.getInitialData();
      // Get favorite categories separately since they're not in initial data
      final favoriteCategories = await repository.getFavoriteCategories();

      if (mounted) {
        setState(() {
          _categories = initialData.categories;
          _favorites = favoriteCategories;
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

      // Show a loading indicator or disable the button during the operation
      setState(() {
        // This prevents multiple clicks while operation is in progress
      });

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

  void _toggleCategory(CategoryModel category) {
    setState(() {
      if (_selectedCategories.any((cat) => cat.id == category.id)) {
        _selectedCategories.removeWhere((cat) => cat.id == category.id);
      } else {
        _selectedCategories.add(category);
      }
    });
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
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
                    ..._favorites.map(
                        (category) => _buildCategoryItem(context, category)),
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
                      .where(
                          (cat) => !_favorites.any((fav) => fav.id == cat.id))
                      .map((category) => _buildCategoryItem(context, category)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    widget.onCategoriesSelected(_selectedCategories);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () {
                    widget.onCategoriesSelected(_selectedCategories);
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
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    final isSelected = _selectedCategories.any((cat) => cat.id == category.id);
    final isFavorite = _favorites.any((fav) => fav.id == category.id);

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
        onTap: () => _toggleCategory(category),
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
