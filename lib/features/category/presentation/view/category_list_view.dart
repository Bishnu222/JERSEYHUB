import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/features/category/domain/entity/category_entity.dart';
import 'package:jerseyhub/features/category/presentation/viewmodel/category_viewmodel.dart';
import 'package:jerseyhub/features/category/presentation/widgets/category_card.dart';

class CategoryListView extends StatefulWidget {
  final Function(CategoryEntity?)? onCategorySelected;
  final String? selectedCategoryId;

  const CategoryListView({
    super.key,
    this.onCategorySelected,
    this.selectedCategoryId,
  });

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryViewModel>().add(LoadAllCategoriesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryViewModel, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CategoriesLoaded) {
          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No categories found',
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildCategoriesList(state.categories);
        } else if (state is CategoryError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: ${state.message}',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<CategoryViewModel>().add(
                      LoadAllCategoriesEvent(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Text(
            'No categories available',
            style: TextStyle(
              color:
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoriesList(List<CategoryEntity> categories) {
    // Filter categories to only show those with images
    final categoriesWithImages = categories.where((category) {
      // Check if category has a club logo (based on name)
      final hasClubLogo = _hasClubLogo(category.name);
      // Check if category has a valid imageUrl
      final hasImageUrl =
          category.imageUrl != null && category.imageUrl!.isNotEmpty;

      return hasClubLogo || hasImageUrl;
    }).toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: categoriesWithImages.length + 1, // +1 for "Show All" option
      itemBuilder: (context, index) {
        if (index == 0) {
          // "Show All" option
          final isSelected = widget.selectedCategoryId == null;
          return SizedBox(
            width: 150,
            child: CategoryCard(
              category: CategoryEntity(
                id: '',
                name: 'Show All',
                description: 'View all products',
                imageUrl: null,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isSelected: isSelected,
              onTap: () {
                widget.onCategorySelected?.call(null);
              },
            ),
          );
        } else {
          final category = categoriesWithImages[index - 1];
          final isSelected = widget.selectedCategoryId == category.id;

          return SizedBox(
            width: 150,
            child: CategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () {
                widget.onCategorySelected?.call(category);
              },
            ),
          );
        }
      },
    );
  }

  bool _hasClubLogo(String categoryName) {
    String lowerName = categoryName.toLowerCase();

    return lowerName.contains('barcelona') ||
        lowerName.contains('fcb') ||
        lowerName.contains('manchester') ||
        lowerName.contains('united') ||
        lowerName.contains('man utd') ||
        lowerName.contains('real madrid') ||
        lowerName.contains('madrid') ||
        lowerName.contains('liverpool') ||
        lowerName.contains('lfc');
  }
}
