import 'package:flutter_test/flutter_test.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';

void main() {
  group('Order States', () {
    late List<OrderEntity> testOrders;

    setUp(() {
      // Create test data
      final testProduct = ProductEntity(
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

      final testCartItem = CartItemEntity(
        id: 'cart1',
        product: testProduct,
        quantity: 2,
        selectedSize: 'M',
        addedAt: DateTime(2025, 1, 1),
      );

      testOrders = [
        OrderEntity(
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
        ),
        OrderEntity(
          id: 'order2',
          userId: 'user123',
          items: [testCartItem],
          subtotal: 2500.0,
          shippingCost: 5.99,
          totalAmount: 2505.99,
          status: OrderStatus.processing,
          customerName: 'John Doe',
          customerEmail: 'john@example.com',
          customerPhone: '1234567890',
          shippingAddress: '123 Test St',
          createdAt: DateTime(2025, 1, 2),
          updatedAt: DateTime(2025, 1, 2),
        ),
      ];
    });

    test('OrderInitial should be the default state', () {
      expect(OrderInitial(), isA<OrderState>());
    });

    test('OrderLoading should be a valid state', () {
      expect(OrderLoading(), isA<OrderState>());
    });

    test('OrdersLoaded should contain orders', () {
      final state = OrdersLoaded(orders: testOrders);
      expect(state, isA<OrderState>());
      expect(state.orders, testOrders);
      expect(state.orders.length, 2);
    });

    test('OrdersLoaded should handle empty orders list', () {
      final state = OrdersLoaded(orders: []);
      expect(state, isA<OrderState>());
      expect(state.orders, isEmpty);
    });

    test('OrderError should contain error message', () {
      final state = OrderError(message: 'Test error message');
      expect(state, isA<OrderState>());
      expect(state.message, 'Test error message');
    });

    test('OrderCreated should contain created order', () {
      final state = OrderCreated(order: testOrders.first);
      expect(state, isA<OrderState>());
      expect(state.order, testOrders.first);
    });

    test('OrderUpdated should contain updated order', () {
      final state = OrderUpdated(order: testOrders.first);
      expect(state, isA<OrderState>());
      expect(state.order, testOrders.first);
    });

    test('OrderDeleted should contain deleted order ID', () {
      final state = OrderDeleted(orderId: 'order1');
      expect(state, isA<OrderState>());
      expect(state.orderId, 'order1');
    });

    test('OrdersLoaded should validate order data', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;

      expect(order.id.isNotEmpty, true);
      expect(order.userId?.isNotEmpty ?? false, true);
      expect(order.items.isNotEmpty, true);
      expect(order.totalAmount > 0, true);
      expect(order.customerName.isNotEmpty, true);
      expect(order.customerEmail.isNotEmpty, true);
      expect(order.customerPhone.isNotEmpty, true);
      expect(order.shippingAddress.isNotEmpty, true);
    });

    test('OrdersLoaded should handle different order statuses', () {
      final state = OrdersLoaded(orders: testOrders);
      final pendingOrder = state.orders.first;
      final processingOrder = state.orders.last;

      expect(pendingOrder.status, OrderStatus.pending);
      expect(processingOrder.status, OrderStatus.processing);
    });

    test('OrdersLoaded should calculate order totals correctly', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;
      final expectedTotal = order.subtotal + order.shippingCost;

      expect(order.totalAmount, expectedTotal);
    });

    test('OrdersLoaded should handle order dates correctly', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;

      expect(
        order.createdAt.isBefore(DateTime.now()) ||
            order.createdAt.isAtSameMomentAs(DateTime.now()),
        true,
      );
      expect(
        order.updatedAt.isBefore(DateTime.now()) ||
            order.updatedAt.isAtSameMomentAs(DateTime.now()),
        true,
      );
    });

    test('OrdersLoaded should handle order with multiple items', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;
      expect(order.itemCount, 2); // itemCount uses item.quantity (2)

      // Test with multiple items
      final testProduct2 = ProductEntity(
        id: '2',
        team: 'Barcelona',
        type: 'Away',
        size: 'L',
        price: 3000.0,
        quantity: 5,
        categoryId: 'cat2',
        productImage: 'test2.jpg',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );

      final testCartItem2 = CartItemEntity(
        id: 'cart2',
        product: testProduct2,
        quantity: 1,
        selectedSize: 'L',
        addedAt: DateTime(2025, 1, 1),
      );

      final multiItemOrder = order.copyWith(
        items: [order.items.first, testCartItem2],
      );

      expect(
        multiItemOrder.itemCount,
        3,
      ); // 2 (first item) + 1 (second item) = 3
    });

    test('OrdersLoaded should validate customer information', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;

      // Test email format (basic validation)
      expect(order.customerEmail.contains('@'), true);
      expect(order.customerEmail.contains('.'), true);

      // Test phone number (basic validation)
      expect(order.customerPhone.length >= 10, true);

      // Test required fields
      expect(order.customerName.isNotEmpty, true);
      expect(order.shippingAddress.isNotEmpty, true);
    });

    test('OrdersLoaded should handle order amounts correctly', () {
      final state = OrdersLoaded(orders: testOrders);
      final order = state.orders.first;

      expect(order.subtotal >= 0, true);
      expect(order.shippingCost >= 0, true);
      expect(order.totalAmount >= 0, true);
      expect(order.totalAmount >= order.subtotal, true);
    });

    test('OrderError should handle different error messages', () {
      final error1 = OrderError(message: 'Network error');
      final error2 = OrderError(message: 'Database error');
      final error3 = OrderError(message: 'Authentication error');

      expect(error1.message, 'Network error');
      expect(error2.message, 'Database error');
      expect(error3.message, 'Authentication error');
    });

    test('OrderCreated should validate created order', () {
      final state = OrderCreated(order: testOrders.first);
      final order = state.order;

      expect(order.id.isNotEmpty, true);
      expect(order.userId?.isNotEmpty ?? false, true);
      expect(order.items.isNotEmpty, true);
      expect(order.totalAmount > 0, true);
    });

    test('OrderUpdated should validate updated order', () {
      final state = OrderUpdated(order: testOrders.first);
      final order = state.order;

      expect(order.id.isNotEmpty, true);
      expect(order.userId?.isNotEmpty ?? false, true);
      expect(order.items.isNotEmpty, true);
      expect(order.totalAmount > 0, true);
    });

    test('OrderDeleted should validate deleted order ID', () {
      final state = OrderDeleted(orderId: 'order1');

      expect(state.orderId.isNotEmpty, true);
      expect(state.orderId, 'order1');
    });

    test('Order states should be comparable', () {
      final initial1 = OrderInitial();
      final initial2 = OrderInitial();
      final loading1 = OrderLoading();
      final loading2 = OrderLoading();

      expect(initial1, equals(initial2));
      expect(loading1, equals(loading2));
    });

    test('OrdersLoaded states should be comparable', () {
      final loaded1 = OrdersLoaded(orders: testOrders);
      final loaded2 = OrdersLoaded(orders: testOrders);

      expect(loaded1, equals(loaded2));
    });

    test('OrderError states should be comparable', () {
      final error1 = OrderError(message: 'Test error');
      final error2 = OrderError(message: 'Test error');

      expect(error1, equals(error2));
    });
  });
}
