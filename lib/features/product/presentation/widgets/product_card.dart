import 'package:flutter/material.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: _buildProductImage(),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Team Name
                    Flexible(
                      child: Text(
                        product.team,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Type and Size
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(product.type),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.type,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showSizeSelector(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Size ${product.size}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 12,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price and Stock Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'रू${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        if (product.quantity > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 10,
                                  color: Colors.green[700],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'In Stock (${product.quantity})',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[200]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cancel,
                                  size: 10,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Out of Stock',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    // Try to load from assets first, then fallback to network or placeholder
    if (product.productImage.startsWith('assets/')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: Image.asset(
          product.productImage,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            print(
              '❌ Asset image load error for ${product.productImage}: $error',
            );
            // Try to use a different asset image as fallback
            return _buildAssetFallbackImage();
          },
        ),
      );
    } else if (product.productImage.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[200],
        child: Image.network(
          product.productImage,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          cacheWidth: null, // Disable caching
          cacheHeight: null, // Disable caching
          key: ValueKey(
            '${product.id}-${product.productImage}-${DateTime.now().millisecondsSinceEpoch}',
          ), // Force rebuild with timestamp
          errorBuilder: (context, error, stackTrace) {
            print('❌ Image load error for ${product.productImage}: $error');
            return _buildPlaceholderImage();
          },
        ),
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.sports_soccer, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildAssetFallbackImage() {
    // List of all available asset images
    List<String> fallbackImages = [
      'assets/images/Real_Madrid.png',
      'assets/images/Real_Madrid_Away_2019-20.png',
      'assets/images/Liverpool.png',
      'assets/images/Liverpool_FC_Home_Jersey.webp',
      'assets/images/Barcelona.png',
      'assets/images/Barcelona_Away_jersey.png',
      'assets/images/Manchester_United.png',
      'assets/images/Manchester_United_FC_Jersey.png',
    ];

    // Use product ID to consistently select a fallback image
    int index = product.id.hashCode.abs() % fallbackImages.length;
    String fallbackImage = fallbackImages[index];

    print('🔄 Using fallback asset image: $fallbackImage');

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Image.asset(
        fallbackImage,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          print('❌ Fallback asset image also failed: $fallbackImage - $error');
          return _buildPlaceholderImage();
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Colors.blue;
      case 'away':
        return Colors.red;
      case 'third':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showSizeSelector(BuildContext context) {
    final List<String> availableSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Title
              Text(
                'Select Size for ${product.team}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Size grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemCount: availableSizes.length,
                itemBuilder: (context, index) {
                  final size = availableSizes[index];
                  final isCurrentSize = size == product.size;

                  return GestureDetector(
                    onTap: () {
                      // Here you can add logic to update the product size
                      // For now, we'll just show a snackbar
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Size $size selected for ${product.team}',
                          ),
                          duration: const Duration(seconds: 2),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isCurrentSize
                            ? Theme.of(context).primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCurrentSize
                              ? Theme.of(context).primaryColor
                              : Colors.grey[300]!,
                          width: isCurrentSize ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isCurrentSize
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
