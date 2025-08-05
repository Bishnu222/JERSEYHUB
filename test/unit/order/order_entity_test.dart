import 'package:flutter_test/flutter_test.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';

void main() {
  group('OrderEntity Unit Tests', () {
    late OrderEntity testOrder;
    late ProductEntity testProduct;
    late CartItemEntity testCartItem;

    setUp(() {
      testProduct = ProductEntity(
        id: '1',
        team: 'Real Madrid',
        type: 'Home',
        size: 'M',
        price: 2500.0,
        quantity: 10,
        categoryId: 'cat1',
        productImage: 'test.jpg',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      testCartItem = CartItemEntity(
        id: 'cart1',
        product: testProduct,
        quantity: 2,
        selectedSize: 'M',
        addedAt: DateTime(2025, 1, 1),
      );

      testOrder = OrderEntity(
        id: 'order1',
        userId: 'user123',
        items: [testCartItem],
        subtotal: 5000.0,
        shippingCost: 5.99,
        totalAmount: 5005.99,
        status: OrderStatus.pending,
        customerName: 'John Doe',
        customerEmail: 'john@example.com',
        customerPhone: '1234567890',
        shippingAddress: '123 Test St',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
    });

    test('should create OrderEntity with valid data', () {
      expect(testOrder.id, 'order1');
      expect(testOrder.userId, 'user123');
      expect(testOrder.items.length, 1);
      expect(testOrder.totalAmount, 5005.99);
      expect(testOrder.status, OrderStatus.pending);
    });

    test('should calculate item count correctly', () {
      expect(testOrder.itemCount, 2); // itemCount uses item.quantity (2)
    });

    test('should calculate total amount correctly', () {
      final expectedTotal = testOrder.subtotal + testOrder.shippingCost;
      expect(testOrder.totalAmount, expectedTotal);
    });

    test('should handle different order statuses', () {
      final processingOrder = testOrder.copyWith(
        status: OrderStatus.processing,
      );
      expect(processingOrder.status, OrderStatus.processing);
    });

    test('should validate customer information', () {
      expect(testOrder.customerName.isNotEmpty, true);
      expect(testOrder.customerEmail.contains('@'), true);
      expect(testOrder.customerPhone.length >= 10, true);
      expect(testOrder.shippingAddress.isNotEmpty, true);
    });

    test('should handle order with multiple items', () {
      final testCartItem2 = CartItemEntity(
        id: 'cart2',
        product: testProduct,
        quantity: 1,
        selectedSize: 'L',
        addedAt: DateTime(2025, 1, 1),
      );

      final multiItemOrder = testOrder.copyWith(
        items: [testOrder.items.first, testCartItem2],
      );

      expect(multiItemOrder.itemCount, 3); // 2 + 1 = 3
    });

    test('should create from JSON correctly', () {
      final json = {
        'id': 'order1',
        'userId': 'user123',
        'items': [
          {
            'id': 'cart1',
            'product': {
              'id': '1',
              'team': 'Real Madrid',
              'type': 'Home',
              'size': 'M',
              'price': 2500.0,
              'quantity': 10,
              'categoryId': 'cat1',
              'productImage': 'test.jpg',
            },
            'quantity': 2,
            'selectedSize': 'M',
          },
        ],
        'subtotal': 5000.0,
        'shippingCost': 5.99,
        'totalAmount': 5005.99,
        'status': 'pending',
        'customerName': 'John Doe',
        'customerEmail': 'john@example.com',
        'customerPhone': '1234567890',
        'shippingAddress': '123 Test St',
      };

      final orderFromJson = OrderEntity.fromJson(json);
      expect(orderFromJson.id, 'order1');
      expect(orderFromJson.userId, 'user123');
    });

    test('should convert to JSON correctly', () {
      final json = testOrder.toJson();
      expect(json['id'], 'order1');
      expect(json['userId'], 'user123');
      expect(json['status'], 'pending');
    });

    test('should handle copyWith method', () {
      final updatedOrder = testOrder.copyWith(
        status: OrderStatus.processing,
        totalAmount: 6000.0,
      );

      expect(updatedOrder.status, OrderStatus.processing);
      expect(updatedOrder.totalAmount, 6000.0);
      expect(updatedOrder.id, testOrder.id); // Other fields unchanged
    });

    test('should validate order entity equality', () {
      final order1 = testOrder;
      final order2 = testOrder.copyWith();
      final order3 = testOrder.copyWith(id: 'order2');

      expect(order1, equals(order2));
      expect(order1, isNot(equals(order3)));
    });
  });
}
