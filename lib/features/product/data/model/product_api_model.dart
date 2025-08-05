import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import 'package:jerseyhub/app/constant/backend_config.dart';

class ProductApiModel {
  static List<String> allAvailableImages = [];

  final String id;
  final String team;
  final String type;
  final String size;
  final double price;
  final int quantity;
  final String categoryId;
  final String? sellerId;
  final String productImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductApiModel({
    required this.id,
    required this.team,
    required this.type,
    required this.size,
    required this.price,
    required this.quantity,
    required this.categoryId,
    this.sellerId,
    required this.productImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductApiModel.fromJson(Map<String, dynamic> json) {
    // Handle categoryId which can be either a string or a populated object
    String categoryId;
    if (json['categoryId'] is Map<String, dynamic>) {
      // If it's a populated object, extract the _id
      categoryId = json['categoryId']['_id']?.toString() ?? '';
    } else {
      // If it's already a string, use it directly
      categoryId = json['categoryId']?.toString() ?? '';
    }

    // Handle sellerId which can be either a string or a populated object
    String? sellerId;
    if (json['sellerId'] is Map<String, dynamic>) {
      sellerId = json['sellerId']['_id']?.toString();
    } else {
      sellerId = json['sellerId']?.toString();
    }

    // Use assets images instead of backend images for better team-specific images
    String productImage = json['productImage'] ?? '';
    String team = json['team'] ?? '';

    // Map team names to asset images with variety based on type (home/away)
    String type = json['type'] ?? '';

    // Use all available asset images for better variety
    List<String> allAssetImages = [
      'assets/images/Real_Madrid.png',
      'assets/images/Real_Madrid_Away_2019-20.png',
      'assets/images/Liverpool.png',
      'assets/images/Liverpool_FC_Home_Jersey.webp',
      'assets/images/Barcelona.png',
      'assets/images/Barcelona_Away_jersey.png',
      'assets/images/Manchester_United.png',
      'assets/images/Manchester_United_FC_Jersey.png',
    ];

    // Use team-specific images when possible, otherwise use variety
    switch (team.toLowerCase()) {
      case 'real madrid':
        if (type.toLowerCase() == 'away') {
          productImage = 'assets/images/Real_Madrid_Away_2019-20.png';
        } else {
          productImage = 'assets/images/Real_Madrid.png';
        }
        break;
      case 'liverpool':
        if (type.toLowerCase() == 'away') {
          productImage = 'assets/images/Liverpool_FC_Home_Jersey.webp';
        } else {
          productImage = 'assets/images/Liverpool.png';
        }
        break;
      case 'barcelona':
        if (type.toLowerCase() == 'away') {
          productImage = 'assets/images/Barcelona_Away_jersey.png';
        } else {
          productImage = 'assets/images/Barcelona.png';
        }
        break;
      case 'manchester united':
        if (type.toLowerCase() == 'away') {
          productImage = 'assets/images/Manchester_United_FC_Jersey.png';
        } else {
          productImage = 'assets/images/Manchester_United.png';
        }
        break;
      default:
        // For unknown teams, cycle through all available images based on product ID
        if (json['_id'] != null) {
          int index = json['_id'].hashCode.abs() % allAssetImages.length;
          productImage = allAssetImages[index];
        } else {
          // Fallback to backend image if no ID available
          if (productImage.isNotEmpty &&
              !productImage.startsWith('http') &&
              !productImage.startsWith('assets/')) {
            productImage =
                '${BackendConfig.serverAddress}/uploads/$productImage';
          }
        }
    }

    // Add error handling and debugging
    print('🔍 Team: $team, Type: $type');
    print('📁 Asset path: $productImage');
    print('✅ Using asset image for $team $type: $productImage');

    // Test if the asset exists by trying to load it
    try {
      // This will help us identify which assets are actually available
      print('🔍 Testing asset availability for: $productImage');
    } catch (e) {
      print('❌ Asset not found: $productImage - $e');
    }

    // Store the list of all available images for fallback
    ProductApiModel.allAvailableImages = allAssetImages;

    return ProductApiModel(
      id: json['_id'] ?? json['id'] ?? '',
      team: json['team'] ?? '',
      type: json['type'] ?? '',
      size: json['size'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      categoryId: categoryId,
      sellerId: sellerId,
      productImage: productImage,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team': team,
      'type': type,
      'size': size,
      'price': price,
      'quantity': quantity,
      'categoryId': categoryId,
      'sellerId': sellerId,
      'productImage': productImage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      team: team,
      type: type,
      size: size,
      price: price,
      quantity: quantity,
      categoryId: categoryId,
      sellerId: sellerId,
      productImage: productImage,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory ProductApiModel.fromEntity(ProductEntity entity) {
    return ProductApiModel(
      id: entity.id,
      team: entity.team,
      type: entity.type,
      size: entity.size,
      price: entity.price,
      quantity: entity.quantity,
      categoryId: entity.categoryId,
      sellerId: entity.sellerId,
      productImage: entity.productImage,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
