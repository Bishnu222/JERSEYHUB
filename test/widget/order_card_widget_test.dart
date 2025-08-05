import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jerseyhub/features/order/domain/entity/order_entity.dart';
import 'package:jerseyhub/features/order/presentation/widgets/order_card_widget.dart';
import 'package:jerseyhub/features/order/presentation/viewmodel/order_viewmodel.dart';
import 'package:jerseyhub/features/cart/domain/entity/cart_item_entity.dart';
import 'package:jerseyhub/features/product/domain/entity/product_entity.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_all_orders_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/get_order_by_id_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/create_order_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/update_order_status_usecase.dart';
import 'package:jerseyhub/features/order/domain/use_case/delete_order_usecase.dart';
import 'package:jerseyhub/features/order/domain/repository/order_repository.dart';
import 'package:jerseyhub/app/shared_prefs/user_shared_prefs.dart';
import 'package:dartz/dartz.dart';
import 'package:jerseyhub/core/error/failure.dart';

class FakeUserSharedPrefs implements UserSharedPrefs {
  @override
  Future<void> clearUserData() async {}

  @override
  String? getCurrentUserEmail() => 'test@example.com';

  @override
  String? getCurrentUserId() => 'user123';

  @override
  String? getProfileImageUrl() => null;

  @override
  bool isLoggedIn() => true;

  @override
  Future<bool> isUserLoggedIn() async => true;

  @override
  Future<void> setCurrentUserEmail(String email) async {}

  @override
  Future<void> setCurrentUserId(String userId) async {}

  @override
  Future<void> setProfileImageUrl(String imageUrl) async {}

  @override
  Future<void> setUserLoggedIn(String userId, String email) async {}

  @override
  Map<String, dynamic> getAllUserData() {
    return {
      'userId': getCurrentUserId(),
      'userEmail': getCurrentUserEmail(),
      'profileImageUrl': getProfileImageUrl(),
      'isLoggedIn': isLoggedIn(),
    };
  }

  @override
  void printCurrentUserData() {
    final data = getAllUserData();
    print('🔍 FakeUserSharedPrefs: Current user data:');
    data.forEach((key, value) {
      print('  $key: $value');
    });
  }
}

class MockGetAllOrdersUseCase extends GetAllOrdersUseCase {
  MockGetAllOrdersUseCase() : super(_MockOrderRepository());

  @override
  Future<Either<Failure, List<OrderEntity>>> call() async {
    return const Right([]);
  }
}

class MockGetOrderByIdUseCase extends GetOrderByIdUseCase {
  MockGetOrderByIdUseCase() : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }
}

class MockCreateOrderUseCase extends CreateOrderUseCase {
  MockCreateOrderUseCase() : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }
}

class MockUpdateOrderStatusUseCase extends UpdateOrderStatusUseCase {
  MockUpdateOrderStatusUseCase() : super(_MockOrderRepository());

  @override
  Future<Either<Failure, OrderEntity>> call(
    UpdateOrderStatusParams params,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }
}

class MockDeleteOrderUseCase extends DeleteOrderUseCase {
  MockDeleteOrderUseCase() : super(_MockOrderRepository());

  @override
  Future<Either<Failure, void>> call(DeleteOrderParams params) async {
    return const Right(null);
  }
}

class _MockOrderRepository implements OrderRepository {
  @override
  Future<Either<Failure, List<OrderEntity>>> getAllLocalOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getLocalOrderById(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createLocalOrder(
    OrderEntity order,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateLocalOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteLocalOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllRemoteOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getRemoteOrderById(
    String orderId,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createRemoteOrder(
    OrderEntity order,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateRemoteOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteRemoteOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getAllOrders() async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder(OrderEntity order) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
    String orderId,
    String status,
  ) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    return Left(RemoteDatabaseFailure(message: 'Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> clearAllLocalOrders() async {
    return const Right(null);
  }
}

void main() {
  group('OrderCardWidget Widget Tests', () {
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
        id: 'order123',
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

    Widget createTestWidget({OrderEntity? order}) {
      final orderViewModel = OrderViewModel(
        getAllOrdersUseCase: MockGetAllOrdersUseCase(),
        getOrderByIdUseCase: MockGetOrderByIdUseCase(),
        createOrderUseCase: MockCreateOrderUseCase(),
        updateOrderStatusUseCase: MockUpdateOrderStatusUseCase(),
        deleteOrderUseCase: MockDeleteOrderUseCase(),
        userSharedPrefs: FakeUserSharedPrefs(),
      );

      return MaterialApp(
        home: BlocProvider<OrderViewModel>(
          create: (context) => orderViewModel,
          child: Scaffold(
            body: OrderCardWidget(
              order: order ?? testOrder,
              orderViewModel: orderViewModel,
            ),
          ),
        ),
      );
    }

    testWidgets('should display order information correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Order #order123'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('रू5005.99'), findsOneWidget);
    });

    testWidgets('should display correct order status colors', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      // Should display status with appropriate styling
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('should display delete button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should display calendar and shopping bag icons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
    });

    testWidgets('should have InkWell for tap interaction', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should display different statuses correctly', (
      WidgetTester tester,
    ) async {
      final processingOrder = testOrder.copyWith(
        status: OrderStatus.processing,
      );
      await tester.pumpWidget(createTestWidget(order: processingOrder));

      expect(find.text('Processing'), findsOneWidget);
    });

    testWidgets('should handle order with multiple items', (
      WidgetTester tester,
    ) async {
      final testCartItem2 = CartItemEntity(
        id: 'cart2',
        product: testProduct,
        quantity: 1,
        selectedSize: 'L',
        addedAt: DateTime(2025, 1, 1),
      );

      final multiItemOrder = testOrder.copyWith(
        items: [testCartItem, testCartItem2],
      );
      await tester.pumpWidget(createTestWidget(order: multiItemOrder));

      expect(find.byType(OrderCardWidget), findsOneWidget);
    });

    testWidgets('should display correct total amount', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('रू5005.99'), findsOneWidget);
    });

    testWidgets('should have proper card styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle short order ID correctly', (
      WidgetTester tester,
    ) async {
      final shortOrder = testOrder.copyWith(id: '123');
      await tester.pumpWidget(createTestWidget(order: shortOrder));

      expect(find.text('Order #123'), findsOneWidget);
    });
  });
}
