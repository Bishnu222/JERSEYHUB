import 'package:equatable/equatable.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

class OrderEntity extends Equatable {
  final String id;
  final String? userId; // Add user ID for backend association
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final double totalAmount;
  final OrderStatus status;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.totalAmount,
    required this.status,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  OrderEntity copyWith({
    String? id,
    String? userId,
    List<CartItemEntity>? items,
    double? subtotal,
    double? shippingCost,
    double? totalAmount,
    OrderStatus? status,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON for backend API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'products': items
          .map(
            (item) => {
              'name': item.product.team,
              'quantity': item.quantity,
              'price': item.product.price,
              'productImage': item.product.productImage,
            },
          )
          .toList(),
      'total': totalAmount,
      'status': _getStatusString(status),
      'customerInfo': {
        'name': customerName,
        'email': customerEmail,
        'phone': customerPhone,
        'address': shippingAddress,
      },
      'paymentMethod': 'esewa', // Default payment method
      'trackingNumber': trackingNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from JSON from backend API
  factory OrderEntity.fromJson(Map<String, dynamic> json) {
    print('📦 OrderEntity: Parsing order from JSON: ${json['_id']}');

    // Convert backend products to cart items
    List<CartItemEntity> cartItems = [];
    if (json['products'] != null) {
      print(
        '📦 OrderEntity: Found ${(json['products'] as List).length} products',
      );
      cartItems = (json['products'] as List).map((productJson) {
        print('📦 OrderEntity: Parsing product: ${productJson['name']}');
        print('📦 OrderEntity: Product image: ${productJson['productImage']}');

        // Create a minimal ProductEntity for the cart item
        final product = ProductEntity(
          id: productJson['_id'] ?? '',
          team: productJson['name'] ?? '',
          type: '',
          size: '',
          price: (productJson['price'] ?? 0.0).toDouble(),
          quantity: productJson['quantity'] ?? 0,
          categoryId: '',
          sellerId: null,
          productImage: productJson['productImage'] ?? '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return CartItemEntity(
          id: productJson['_id'] ?? '',
          product: product,
          quantity: productJson['quantity'] ?? 0,
          selectedSize: '',
          addedAt: DateTime.now(),
        );
      }).toList();
    }

    // Handle customer info from the new backend schema
    String customerName = '';
    String customerEmail = '';
    String customerPhone = '';
    String shippingAddress = '';

    // Check if customerInfo object exists (new schema)
    if (json['customerInfo'] != null) {
      final customerInfo = json['customerInfo'] as Map<String, dynamic>;
      customerName = customerInfo['name'] ?? '';
      customerEmail = customerInfo['email'] ?? '';
      customerPhone = customerInfo['phone'] ?? '';
      shippingAddress = customerInfo['address'] ?? '';
    } else {
      // Fallback to old schema (direct fields)
      customerName = json['customerName'] ?? '';
      customerEmail = json['customerEmail'] ?? '';
      customerPhone = json['customerPhone'] ?? '';
      shippingAddress = json['shippingAddress'] ?? '';
    }

    return OrderEntity(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'],
      items: cartItems,
      subtotal: (json['total'] ?? 0.0).toDouble(),
      shippingCost: 0.0, // Backend doesn't store shipping cost separately
      totalAmount: (json['total'] ?? 0.0).toDouble(),
      status: _getStatusFromString(json['status'] ?? 'pending'),
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      trackingNumber: json['trackingNumber'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : (json['date'] != null
                ? DateTime.parse(json['date'])
                : DateTime.now()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : (json['createdAt'] != null
                ? DateTime.parse(json['createdAt'])
                : DateTime.now()),
    );
  }

  // Helper methods for JSON conversion
  static String _getStatusString(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  static OrderStatus _getStatusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    items,
    subtotal,
    shippingCost,
    totalAmount,
    status,
    customerName,
    customerEmail,
    customerPhone,
    shippingAddress,
    trackingNumber,
    createdAt,
    updatedAt,
  ];
}
