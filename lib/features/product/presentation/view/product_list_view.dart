import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/app/service_locator/service_locator.dart';
import 'package:jerseyhub/features/category/domain/entity/category_entity.dart';
import 'package:jerseyhub/features/category/presentation/view/category_list_view.dart';
import 'package:jerseyhub/features/category/presentation/viewmodel/category_viewmodel.dart';
import 'package:jerseyhub/features/cart/presentation/viewmodel/cart_viewmodel.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import 'package:jerseyhub/features/product/presentation/view/product_detail_view.dart';
import 'package:jerseyhub/features/product/presentation/viewmodel/product_viewmodel.dart';
import 'package:jerseyhub/features/product/presentation/widgets/product_card.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({super.key});

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final TextEditingController _searchController = TextEditingController();
  CategoryEntity? _selectedCategory;

  @override
  void initState() {
    super.initState();
    context.read<ProductViewModel>().add(LoadAllProductsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      // If a category is selected, we should search within that category
      // For now, we'll use the general search and filter client-side
      // TODO: Implement server-side search within category
      context.read<ProductViewModel>().add(SearchProductsEvent(query: query));
    } else {
      // If no search query, show products based on current category selection
      if (_selectedCategory == null) {
        context.read<ProductViewModel>().add(LoadAllProductsEvent());
      } else {
        context.read<ProductViewModel>().add(
          LoadProductsByCategoryEvent(categoryId: _selectedCategory!.id),
        );
      }
    }
  }

  void _onCategorySelected(CategoryEntity? category) {
    setState(() {
      _selectedCategory = category;
    });

    if (category == null) {
      // Show All selected
      context.read<ProductViewModel>().add(LoadAllProductsEvent());
    } else {
      // Specific category selected
      context.read<ProductViewModel>().add(
        LoadProductsByCategoryEvent(categoryId: category.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search jerseys...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _onSearch('');
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: _onSearch,
          ),
        ),
        // Categories
        SizedBox(
          height: 120,
          child: BlocProvider(
            create: (context) => serviceLocator<CategoryViewModel>(),
            child: CategoryListView(
              selectedCategoryId: _selectedCategory?.id,
              onCategorySelected: _onCategorySelected,
            ),
          ),
        ),
        // Products Grid
        Expanded(
          child: BlocBuilder<ProductViewModel, ProductState>(
            builder: (context, state) {
              if (state is ProductLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductsLoaded) {
                if (state.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
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
                return _buildProductsGrid(state.products);
              } else if (state is ProductError) {
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
                          context.read<ProductViewModel>().add(
                            LoadAllProductsEvent(),
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
                  'No products available',
                  style: TextStyle(
                    fontSize: 18,
                    color:
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid(List<ProductEntity> products) {
    List<ProductEntity> filteredProducts;

    if (_selectedCategory != null) {
      // If a category is selected, filter products by that club
      filteredProducts = products.where((product) {
        return _matchesSelectedCategory(product.team, _selectedCategory!.name);
      }).toList();
    } else {
      // If no category selected, show all products from supported clubs
      filteredProducts = products.where((product) {
        return _hasClubLogo(product.team);
      }).toList();
    }

    if (filteredProducts.isEmpty) {
      String message = _selectedCategory != null
          ? 'No ${_selectedCategory!.name} jerseys found'
          : 'No products from supported clubs found';

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedCategory == null) ...[
              SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            // Navigate to product detail page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context) => serviceLocator<ProductViewModel>(),
                    ),
                    BlocProvider(
                      create: (context) => serviceLocator<CartViewModel>(),
                    ),
                  ],
                  child: ProductDetailView(
                    productId: product.id,
                    initialProduct: product,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool _hasClubLogo(String teamName) {
    String lowerName = teamName.toLowerCase();

    // Check for Atletico Madrid first and exclude it
    if (lowerName.contains('atletico') ||
        lowerName.contains('atletico madrid') ||
        lowerName.contains('atleti')) {
      return false;
    }

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

  bool _matchesSelectedCategory(String productTeam, String categoryName) {
    String lowerTeam = productTeam.toLowerCase();
    String lowerCategory = categoryName.toLowerCase();

    // Map category names to team name patterns
    switch (lowerCategory) {
      case 'barcelona':
        return lowerTeam.contains('barcelona') || lowerTeam.contains('fcb');
      case 'manchester united':
        return lowerTeam.contains('manchester') ||
            lowerTeam.contains('united') ||
            lowerTeam.contains('man utd');
      case 'real madrid':
        return lowerTeam.contains('real madrid') ||
            lowerTeam.contains('madrid');
      case 'liverpool':
        return lowerTeam.contains('liverpool') || lowerTeam.contains('lfc');
      default:
        return false;
    }
  }
}
