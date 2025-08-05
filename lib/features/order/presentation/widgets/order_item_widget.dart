import 'package:flutter/material.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';

class OrderItemWidget extends StatelessWidget {
  final CartItemEntity item;

  const OrderItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildProductImage(),
          const SizedBox(width: 12),
          Expanded(child: _buildProductDetails()),
          _buildPriceInfo(),
        ],
      ),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _getProductImage(),
      ),
    );
  }

  Widget _getProductImage() {
    print('🖼️ OrderItemWidget: Loading image for ${item.product.team}');
    print('🖼️ OrderItemWidget: Image path: ${item.product.productImage}');

    if (item.product.productImage.isEmpty) {
      print('🖼️ OrderItemWidget: Empty image path, using placeholder');
      return _buildPlaceholderImage();
    }

    // Handle asset images
    if (item.product.productImage.startsWith('assets/')) {
      print(
        '🖼️ OrderItemWidget: Loading asset image: ${item.product.productImage}',
      );
      return Image.asset(
        item.product.productImage,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('❌ OrderItemWidget: Asset image error: $error');
          return _buildPlaceholderImage();
        },
      );
    }

    // Handle network images with cache busting
    final imageUrl = item.product.productImage.contains('?')
        ? item.product.productImage
        : '${item.product.productImage}?t=${DateTime.now().millisecondsSinceEpoch}';

    print('🖼️ OrderItemWidget: Loading network image: $imageUrl');

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ OrderItemWidget: Network image error: $error');
        return _buildPlaceholderImage();
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_soccer, color: Colors.grey[600], size: 20),
          const SizedBox(height: 2),
          Text(
            item.product.team.split(' ').first,
            style: TextStyle(
              fontSize: 8,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.team,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          item.product.type,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getTypeColor(item.product.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Size: ${item.selectedSize}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: _getTypeColor(item.product.type),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Qty: ${item.quantity}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'रू${item.product.price.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Total: रू${item.totalPrice.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.green[700],
          ),
        ),
      ],
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'home':
        return Colors.red;
      case 'away':
        return Colors.blue;
      case 'third':
        return Colors.purple;
      case 'training':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
